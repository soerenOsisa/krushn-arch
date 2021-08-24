#!/bin/bash

echo "Arch Installer"

# Set up network connection
read -p 'Are you connected to internet? [y/N]: ' neton
if ! [ $neton = 'y' ] && ! [ $neton = 'Y' ]
then 
    echo "Connect to internet to continue..."
    exit
fi

# Filesystem
lsblk
read -p "Enter Disk to use: " drive
sfdisk /dev/$drive -f -w auto -X dos << EOF
,524288,L,*
;
EOF

# Format the partitions
mkfs.ext4 /dev/$drive"2"
mkfs.fat -F32 /dev/$drive"1"

# Set up time
timedatectl set-ntp true

# Mount the partitions
mount /dev/$drive"2" /mnt
mkdir -pv /mnt/boot/efi
mount /dev/$drive"1" /mnt/boot/efi

#upadate mirrors
echo "Updating mirrors for faster download speed"
reflector -a 12 -l 24 -f 12 --sort rate --save /etc/pacman.d/mirrorlist

# Install Arch Linux
echo "Starting install.."
echo "Installing Arch Linux, Xmonad as WM, GRUB2 as bootloader" 
pacstrap /mnt base base-devel linux linux-firmware zsh openssh wget git grub os-prober networkmanager amd-ucode intel-ucode efibootmgr iw wpa_supplicant xorg xf86-video-intel xf86-video-vesa xf86-video-ati xf86-video-amdgpu xf86-video-nouveau xf86-video-fbdev vim neofetch htop

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into new system
cat post-install.sh | arch-chroot /mnt /bin/bash

# Finish
echo "If post-install.sh was run succesfully, you will now have a fully working bootable Arch Linux system installed."
echo "The only thing left is to reboot into the new system."
echo "Press any key to reboot or Ctrl+C to cancel..."
read tmpvar
reboot
