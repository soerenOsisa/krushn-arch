#! /bin/bash

# Set date time
echo $(ls /usr/share/zoneinfo)
read -p "select region:" region
echo $(ls /usr/share/zoneinfo/$region)
read -p "select city:" city
ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc

# Set locale to en_US.UTF-8 UTF-8
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Set hostname
read -p "select hostname:" hostname
echo $hostname > /etc/hostname
echo "127.0.1.1 "$hostname".local  "$hostname > /etc/hosts

# Generate initramfs
mkinitcpio -P

# Set root password
passwd

# Install bootloader
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch
grub-mkconfig -o /boot/grub/grub.cfg

# Create new user
read -p "select username": user
useradd -m -G wheel,power,input,storage,uucp,network -s /usr/bin/zsh $user
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
echo "Set password for "$user":"
passwd s

# Setup window manager
mkdir -p ~/.xmonad
echo 'import XMonad
main = xmonad def
    { terminal    = "urxvt"
    , modMask     = mod4Mask
    , borderWidth = 3
    }' > ~/.xmonad/xmonad.hs
systemctl enable lightdm
echo "exec xmonad" > ~/.xinitrc


# Enable services
systemctl enable NetworkManager

exit