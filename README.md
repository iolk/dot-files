# ArchLinux Install

> Updated on 13 Dec 2020	

> Attention: this installation guide is just the detailed procedure that i followed to install ArchLinux on my HP Elitebook 8470p so it does not take into account problems on other machines

> If you have already installed Arch please go to "ArchLinux Configuration" section below

**First** follow the [ArchLinux Installation Guide ](https://wiki.archlinux.org/index.php/Installation_guide) until the disk partition section

## Partitioning

I choose to use UEFI with GPT partition table. 

> Reason ["You are using Arch. Why would you even consider legacy anything?"](https://bbs.archlinux.org/viewtopic.php?pid=1717395#p1717395)

This is my partition scheme

| Mount point | Partition type       | Size         |
|-------------|----------------------|--------------|
| /mnt/boot   | EFI system partition | 512M         |
| [SWAP]      | Linux swap           | 6G (6GB RAM) |
| /mnt        | Linux x86-64 root (/)       | Remainder    |	

From now i suppose that the disk to partitionate is `/dev/sda` To make this partiotion scheme:

- Remove all the partitions with `fdisk` or `gdisk`
- Check with `fdisk -l /dev/sda` if your hard drive has `Disklabel type: gpt` if not convert it to GPT with `sgdisk -g /dev/sda`
- Make the partitions with `gdisk`
 
 | Partition type        | gdisk code |
|-----------------------|------------|
| EFI system partition  | ef00       |
| Linux swap            | 8200       |
| Linux x86-64 root (/) | 8304       |

## Format Partitions

It's [recommended](https://wiki.archlinux.org/index.php/EFI_system_partition#Format_the_partition) to use FAT32 for the EFI System Partition

```bash
mkfs.ext4 /dev/sda3
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
```

## Mount the file systems

```bash
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2
```

## Install essential packages

```bash
pacstrap /mnt base linux linux-firmware
```

I prefer to install other packages while chrooted.

## Generate Fstab

Insted of using `-U` option i decided to use PARTUUID as source identifier since i choose GPT

```bash
genfstab -t PARTUUID /mnt >> /mnt/etc/fstab
```

Then follow the [system configuration section](https://wiki.archlinux.org/index.php/Installation_guide#Configure_the_system) until the bootloader

## Install some useful stuff

While chrooted please make sure that you install those in order to have a usable system when rebooted. Especially net-tools,iw and iwd for the network and WiFi

```bash
pacman -S nano net-tools htop iw iwd zsh intel-ucode git reflector curl
```

## Bootloader

Since i had some problems with the HP UEFI firmware i decided to use [GRUB](https://wiki.archlinux.org/index.php/GRUB) as bootloader instead of use [UEFI directly](https://wiki.archlinux.org/index.php/EFISTUB#Using_UEFI_directly) BUT i will remove GRUB as soon as possible

### GRUB Installation

**First [check your firmware bitness](https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface#Checking_the_firmware_bitness)**

**Please make sure that you have installed the microcode (intel-ucode or amd-ucode	) before installing GRUB**

While chrooted follow the [GRUB UEFI Installation](https://wiki.archlinux.org/index.php/GRUB#UEFI_systems):

```bash
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
```

> Remeber that if you firmware bitness is 32 you have to use `--target=i386-efi`

### For HP users

> I don't know if that applies to all HPs but it's worth to check

As described in [HP Elitebook 840 G1 UEFI setup](https://wiki.archlinux.org/index.php/HP_EliteBook_840_G1#UEFI_Setup): "The problem is that HP hard coded the paths for the OS boot manager in their UEFI boot manager to `\EFI\Microsoft\Boot\bootmgfw.efi` to boot Microsoft Windows, regardless of how the UEFI NVRAM variables are changed"

With the HP Elitebook 8470p i experienced the same issue and followed the **"Using the Customized Boot path option"** section  **but remember ** that your EFI path is `\EFI\GRUB\grubx64.efi` **not ** `\EFI\grub\grubx64.efi`

Then finally boot your ArchLinux

```bash
exit
umount -R /mnt
reboot
```


# ArchLinux Configuration

## Configure ZSH

```bash
chsh -s /bin/zsh
```

## WiFi Connection

> The wired connection is not covered yet

If you installed the packages in the **"Install some useful stuff"** then:

```bash
systemctl enable systemd-networkd
systemctl enable systemd-resolver
systemctl enable iwd
systemctl start systemd-networkd
systemctl start systemd-resolver
systemctl start iwd

ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

Then run `iwctl` and connect to a wireless network

```bash
station wlan0 scan
station wlan0 get-networks
station wlan0 connect your_network
```

and then try to `ping google.com`. It should work.

## Add and log as a non-root user

First install `sudo` and allow the `wheel` group to run it

```bash
pacman -S sudo 
EDITOR=nano visudo
```

Then simply uncomment the `%wheel ALL=(ALL) ALL` line and add your user

```bash
useradd -m -G rfkill,uucp,wheel,tty,power,audio,users -s /bin/zsh your_fancy_username
passwd your_fancy_username
exit
```

References: [Sudo](https://wiki.archlinux.org/index.php/sudo) and [Users and groups](https://wiki.archlinux.org/index.php/Users_and_groups)

## Installing packages

**Optional:** if you want to speed-up the download you can run [reflector](https://wiki.archlinux.org/index.php/reflector):

```bash
sudo reflector --verbose --latest 30 --sort rate --save /etc/pacman.d/mirrorlist
```

Please install [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) (check the link instructions)

Then to install all the packages:

```bash
cd ~
git clone https://github.com/iolk/dot-files.git
mv dot-files/* ./
mv dot-files/.* ./
rmdir dot-files
cat .pkg-list | xargs sudo apt-get install
```

> You can check and modify the packages in the .pkg-list if you want

## Optional configs

### RClone with Drive

In order to syncronize my KeePass file between devices i use Google Drive. I decided to use RClone to mount my drive directory.

Simply run `rclone configure` and configure a remote (in this case a Google Drive remote) and then:

 - Check the file `~/.config/systemd/user/keepassondrive.service` (set proper dirs/remote)
 - `systemctl --user enable keepassondrive`

That allows you to mount you remote directory as soon as the internet connection is established

### Update redshift coordinates

```bash
nano ~/.config/redshift/redshift.conf
```

# Todos

 - [ ] [Remove GRUB](https://wiki.archlinux.org/index.php/EFISTUB#Using_UEFI_directly)
 - [ ] [Secure Boot](https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface/Secure_Boot)
 - [ ] Security
 - [ ] [USB automount](https://wiki.archlinux.org/index.php/Fstab#External_devices)
 - [ ] Full HW Virtualizzation (qemu)
 - [ ] Docker & K8s
 - [ ] Maintenance (script/guide)
 - [ ] Music Player
 - [ ] Encription
 - [ ] Customize all notifications
 - [x] List of application
 - [x] My ArchLinux install guide
