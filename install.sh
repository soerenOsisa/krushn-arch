#!/bin/bash

# This is Krushn's Arch Linux Installation Script.
# Visit krushndayshmookh.github.io/krushn-arch for instructions.

echo "Arch Installer"

# Set up network connection
read -p 'Are you connected to internet? [y/N]: ' neton
if ! [ $neton = 'y' ] && ! [ $neton = 'Y' ]
then 
    echo "Connect to internet to continue..."
    exit
fi

# Filesystem mount warning
lsblk
read -p "Enter Disk to use:" drive

# to create the partitions programatically (rather than manually)
# https://superuser.com/a/984637
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/$drive
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +512M # 512 MB boot parttion
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  a # make a partition bootable
  1 # bootable partition is partition 1 -- /dev/sda1
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
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
pacstrap /mnt base base-devel zsh grml-zsh-config grub os-prober networkmanager amd-ucode intel-ucode efibootmgr dosfstools freetype2 fuse2 mtools iw wpa_supplicant dialog xorg xorg-server xorg-xinit mesa xf86-video-intel xf86-video-vesa xf86-video-ati xf86-video-amdgpu xf86-video-nouveau xf86-video-fvdev xmonad xmonad-contrib lightdm urxvt dolphin

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Copy post-install system cinfiguration script to new /root
cp -rfv post-install.sh /mnt/root
chmod a+x /mnt/root/post-install.sh

# Chroot into new system
cat /mnt/root/post-install.sh | arch-chroot /mnt /bin/bash

# Finish
echo "If post-install.sh was run succesfully, you will now have a fully working bootable Arch Linux system installed."
echo "The only thing left is to reboot into the new system."
echo "Press any key to reboot or Ctrl+C to cancel..."
read tmpvar
reboot
