#!/bin/bash

# Set date time
ls /usr/share/zoneinfo
read -p "select region: " region
ls /usr/share/zoneinfo/$region
read -p "select city: " city
ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc

# Set locale to en_US.UTF-8 UTF-8
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set hostname
read -p "select hostname: " hostname
echo $hostname > /etc/hostname
echo "127.0.1.1 "$hostname".local  "$hostname > /etc/hosts

# Generate initramfs
mkinitcpio -P

# Set root password
passwd

# Install bootloader
sed -i "s/TIMEOUT=5/TIMEOUT=0/g" /etc/default/grub
sed -i "s/TIMEOUT_STYLE=menu/TIMEOUT_STYLE=hidden/g" /etc/default/grub
sed -i "s/="loglevel=3 quiet"/="loglevel=0 quiet splash"/g" /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch
grub-mkconfig -o /boot/grub/grub.cfg

# Create new user
read -p "select username": user
useradd -m -g wheel -s /usr/bin/zsh $user
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
echo "Set password for "$user": "
passwd s

# Setup desktop environment
pacman -S powerline poweline-fonts plasma-desktop konsole plasma-nm lightdm-gtk-greeter
systemctl enable lightdm
echo "exec plasma" > ~/.xinitrc
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sed -i 's/robbyrussell/agnoster/g' ~/.zshrc

# Misc
systemctl enable NetworkManager
echo "[[ -f ~/.profile ]] && . ~/.profile" > ~/.bash_profile

exit