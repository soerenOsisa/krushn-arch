#!/bin/bash

# Set date time
region=$(cat timezone)
ln -sf /usr/share/zoneinfo/$region /etc/localtime
hwclock --systohc

# Set locale to en_US.UTF-8 UTF-8
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set hostname
hostname=$(cat hostname)
echo $hostname > /etc/hostname
echo "127.0.1.1 "$hostname".local  "$hostname > /etc/hosts
systemctl enable NetworkManager

# Generate initramfs
mkinitcpio -P

# Set root password
pw=$(cat pw)
echo -e $pw"\n"$pw | passwd

# Install bootloader
sed -i "s/TIMEOUT=5/TIMEOUT=0/g" /etc/default/grub
sed -i "s/TIMEOUT_STYLE=menu/TIMEOUT_STYLE=hidden/g" /etc/default/grub
sed -i 's/="loglevel=3 quiet"/="loglevel=0 quiet splash"/g' /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch
grub-mkconfig -o /boot/grub/grub.cfg

# Create new user
user=$(cat user)
useradd -m -g wheel -s /usr/bin/zsh $user
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
echo -e $pw"\n"$pw | passwd s

# Setup desktop environment
yes | pacman -S powerline powerline-fonts plasma-desktop konsole plasma-nm sddm dolphin
systemctl enable sddm
echo "exec plasma" > ~/.xinitrc
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
echo -e "yes\nsed -i 's/robbyrussell/agnoster/g' ~/.zshrc\ncp -r .oh-my-zsh /home/s/\nexit" | sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

exit