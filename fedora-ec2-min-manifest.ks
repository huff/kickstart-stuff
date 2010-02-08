# Kickstart file to build Fedora bases Amazon EC2 image
# This is based of the AOS from the work at http://www.thincrust.net

lang C
keyboard us
timezone US/Eastern
auth --useshadow --enablemd5
selinux --permissive
firewall --enabled --service=ssh
bootloader --timeout=1 --append="acpi=force"
network --bootproto=dhcp --device=eth0 --onboot=on
services --enabled=network,sshd

#
# Uncomment the next line
# to make the root password be thincrust
# By default the root password is emptied
#rootpw --iscrypted $1$uw6MV$m6VtUWPed4SqgoW6fKfTZ/

#
# Partition Information. Change this as necessary
# This information is used by appliance-tools but
# not by the livecd tools.
#
part / --size 650 --fstype ext3 --ondisk sda

#
# Repositories
#
# To compose against the current release tree, use the following "repo" (enabled by default)
repo --name=released --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-12&arch=$basearch
# To include updates, use the following "repo" (enabled by default)
repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f12&arch=$basearch

# To compose against rawhide, use the following "repo" (disabled by default)
#repo --name=rawhide --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=rawhide&arch=$basearch

# To compose against local trees, (edit and) use:
#repo --name=f10 --baseurl=http://localrepo/fedora/releases/12/Everything/$basearch/os/
#repo --name=f10-updates --baseurl=http://localrepo/fedora/updates/12/$basearch/

#
# Add all the packages after the base packages
#
%packages --excludedocs --nobase
bash
kernel
kernel-debug
grub
e2fsprogs
passwd
policycoreutils
chkconfig
rootfiles
yum
vim-minimal
acpid
#needed to disable selinux
lokkit

#Allow for dhcp access
dhclient
iputils

#
# Packages to Remove
#

# no need for kudzu if the hardware doesn't change
-kudzu
-prelink
-setserial
-ed

# Remove the authconfig pieces
-authconfig
-rhpl
-wireless-tools

# Remove the kbd bits
-kbd
-usermode

# these are all kind of overkill but get pulled in by mkinitrd ordering
-mkinitrd
-kpartx
-dmraid
-mdadm
-lvm2
-tar

# selinux toolchain of policycoreutils, libsemanage, ustr
-policycoreutils
-checkpolicy
-selinux-policy*
-libselinux-python
-libselinux

# Extra Things it would be nice to loose

%end

#
# Add custom post scripts after the base post.
#
%post
# Do Ec2 stuff
%end

%post
# Create post-image processing manifests
manifests=/tmp/manifests
mkdir -p $manifests
rpm -qa --qf '%{name}-%{version}-%{release}.%{arch}\n' | sort \
    > $manifests/rpm-manifest-post.txt
rpm -qa --qf '%{sourcerpm}\n' | sort -u > $manifests/srpm-manifest-post.txt
du -akx --exclude=/var/cache/yum / > $manifests/file-manifest-post.txt
du -x --exclude=/var/cache/yum / > $manifests/dir-manifest-post.txt

tar -cvf image-manifests.tar -C /tmp manifests
rm -Rf $manifests
%end

%post
# create ramdisk and kernel images for ec2 images
manifests=/tmp/manifests
mkdir -p $manifests
rpm -qa --qf '%{name}-%{version}-%{release}.%{arch}\n' | sort \
    > $manifests/rpm-manifest-post.txt
rpm -qa --qf '%{sourcerpm}\n' | sort -u > $manifests/srpm-manifest-post.txt
du -akx --exclude=/var/cache/yum / > $manifests/file-manifest-post.txt
du -x --exclude=/var/cache/yum / > $manifests/dir-manifest-post.txt

tar -cvf image-manifests.tar -C /tmp manifests
rm -Rf $manifests
%end

%post --nochroot
# Move manifest tar to build directory
mv $INSTALL_ROOT/image-manifests*.tar .
# Move ramdisk and kernel images to build directory
#mv $INSTALL_ROOT/vmlinuz .
#mv $INSTALL_ROOT/initrd .
%end

