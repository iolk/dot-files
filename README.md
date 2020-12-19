# ArchLinux Install

> Updated on 13 Dec 2020	

> Attention: this installation guide is just the detailed procedure that i followed to install ArchLinux on my HP Elitebook 8470p so it does not take into account problems on other machines

> If you have already installed Arch please go to "ArchLinux Configuration" section below

**First** follow the [ArchLinux Installation Guide ](https://wiki.archlinux.org/index.php/Installation_guide) until the disk partition section

## Partitioning

I choose to use UEFI with GPT partition table. 

> Reason ["You are using Arch. Why would you even consider legacy anything?"](https://bbs.archlinux.org/viewtopic.php?pid=1717395#p1717395)

This is my partition scheme

| Mount point | Partition type        | Size         |
| ----------- | --------------------- | ------------ |
| /mnt/boot   | EFI system partition  | 512M         |
| [SWAP]      | Linux swap            | 6G (6GB RAM) |
| /mnt        | Linux x86-64 root (/) | Remainder    |

From now i suppose that the disk to partitionate is `/dev/sda` To make this partiotion scheme:

- Remove all the partitions with `fdisk` or `gdisk`
- Check with `fdisk -l /dev/sda` if your hard drive has `Disklabel type: gpt` if not convert it to GPT with `sgdisk -g /dev/sda`
- Make the partitions with `gdisk`
 
 | Partition type        | gdisk code |
 | --------------------- | ---------- |
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

Edit `/etc/iwd/main.conf` with:

```bash
[General]
AddressRandomization=once
AddressRandomizationRange=nic
EnableNetworkConfiguration=true
[Network]
NameResolvingService=systemd
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
pacman -S --needed $(comm -12 <(pacman -Slq | sort) <(sort .pkg-list))
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

### Power management

[TLP](https://wiki.archlinux.org/index.php/TLP) & [acpid](https://wiki.archlinux.org/index.php/Acpid)

```bash
systemctl enable tlp
systemctl enable acpid
```

### Fonts

Enable font presets by creating symbolic links:

```bash
sudo ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
```
The above will disable embedded bitmap for all fonts, enable sub-pixel RGB rendering, and enable the LCD filter which is designed to reduce colour fringing when subpixel rendering is used.

### GTK, Icon and Cursor themes 

If you want to change your gtk/icon/cursor theme just install it and run `lxappearance` to set it

To install the cursor theme put the theme files in `~/.icons` in this case you can see the Vimix-cursors folder

Themes used in this configuration:
 - GTK: [Nordic Darker](https://github.com/EliverLara/Nordic)
 - Icon: [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)
 - Cursor: [Vimix](https://github.com/vinceliuice/Vimix-cursors)

#### Dark theme preference

In the `~/.config/gtk-3.0/settings.ini` you can change the `gtk-application-prefer-dark-theme` option

## Kernel-based Virtualizzation

To start [libvirt](https://wiki.archlinux.org/index.php/Libvirt)

```bash
~/.config/i3/scripts/libvirtd_start.sh
```
> For futher configurations: https://libvirt.org/auth.html https://jamielinux.com/docs/libvirt-networking-handbook/ https://www.redhat.com/archives/vfio-users/2015-November/msg00159.html

If `virsh net-list --all` shows no networks make a file `default.xml`: ([ref.](https://blog.programster.org/kvm-missing-default-network))

```xml
<network>
  <name>default</name>
  <uuid>9a05da11-e96b-47f3-8253-a3a482e445f5</uuid>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:0a:cd:21'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
```

then

```bash
sudo virsh net-define --file default.xml
sudo virsh net-start default
sudo virsh net-autostart --network default
```

## Docker

I set up some aliases in the `.zshrc` file so to start/stop the `docker.service` run `dockerd start/stop` and just to try if it works:

```bash
d login
d run -it --rm alpine sh -c "echo hello world"
```

sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose   

d rm $(d ps -aq)
d kill $(d ps -aq)
d rmi $(d images --filter "dangling=true" -q --no-trunc)

# Todos

 - [ ] [Remove GRUB](https://wiki.archlinux.org/index.php/EFISTUB#Using_UEFI_directly)
 - [ ] [Secure Boot](https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface/Secure_Boot)
 - [ ] [Security](https://wiki.archlinux.org/index.php/Security)
 - [ ] Music Player
 - [ ] Wiki Pages
 - [ ] Encription
 - [ ] Customize all notifications
 - [ ] [PCI passthrough](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF#Setting_up_IOMMU)
 - [X] Maintenance (script/guide)
 - [X] Docker
 - [x] [USB automount](https://github.com/coldfix/udiskie)
 - [X] [Kernel-based Virtualizzation](https://wiki.archlinux.org/index.php/KVM)
 - [x] List of application
 - [x] GTK, Icon and cursor theme
 - [x] My ArchLinux install guide
