# Kickstart file to build Fedora Amazon EC2 image
# This is based of the AOS from the work at http://www.thincrust.net

lang C
keyboard us
timezone US/Eastern
auth --useshadow --enablemd5
#selinux --permissive
firewall --enabled --service=ssh
bootloader --timeout=1 --append="acpi=force"
network --bootproto=dhcp --device=eth0 --onboot=on
services --enabled=network,sshd
# for Amazon ec2
device xennet 
device xenblk

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
part / --size 650 --fstype ext4 --ondisk sda

#
# Repositories
#
# To compose against the current release tree, use the following "repo" (enabled by default)
repo --name=released --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-13&arch=$basearch
# To include updates, use the following "repo" (enabled by default)
repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f13&arch=$basearch

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
#kernel-debug - needed for vmlinux?
grub
e2fsprogs
passwd
policycoreutils
selinux-policy-*
chkconfig
rootfiles
yum
acpid

#needed to disable selinux
lokkit

#Allow for dhcp access
dhclient
iputils

#Needed for remote login
openssh-server

#Eucalyptus tools
euca2ools

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
-wireless-tools

# Remove the kbd bits
-kbd
-usermode

# these are all kind of overkill but get pulled in by mkinitrd ordering
# mkinitrd needed to build ec2 ramdisk removed in post
#dracut
-kpartx
-dmraid
-mdadm
-lvm2
-tar

# selinux toolchain of policycoreutils, libsemanage, ustr
#-checkpolicy
#-selinux-policy*
#-libselinux-python
#-libselinux

# Things it would be nice to loose

%end

#
# Add custom post scripts after the base post.
#
%post
# Do Ec2 stuff
cat <<EOL > /etc/fstab
/dev/sda1  /         ext3    defaults        1 1
/dev/sda2  /mnt      ext3    defaults        1 2
/dev/sda3  swap      swap    defaults        0 0
none       /dev/pts  devpts  gid=5,mode=620  0 0
none       /dev/shm  tmpfs   defaults        0 0
none       /proc     proc    defaults        0 0
none       /sys      sysfs   defaults        0 0
EOL

if [ "$(uname -i)" = "x86_64" ]; then
cat <<EOL > /etc/fstab
/dev/sda1  /         ext3    defaults        1 1
/dev/sdb   /mnt      ext3    defaults        0 0
none       /proc     proc    defaults        0 0
none       /sys      sysfs   defaults        0 0
none       /dev/pts  devpts  gid=5,mode=620    0 0
EOL
fi

cat <<EOL > /etc/sysconfig/network-scripts/ifcfg-eth0
ONBOOT=yes
DEVICE=eth0
BOOTPROTO=dhcp
EOL

cat <<EOL >> /etc/rc.local
if [ ! -d /root/.ssh ] ; then
    mkdir -p /root/.ssh
    chmod 0700 /root/.ssh
fi

# Fetch public key using HTTP
curl -f http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key > /tmp/my-key
if [ $? -eq 0 ] ; then
    cat /tmp/my-key >> /root/.ssh/authorized_keys
    chmod 0600 /root/.ssh/authorized_keys
    rm /tmp/my-key
fi

# or fetch public key using the file in the ephemeral store:
if [ -e /mnt/openssh_id.pub ] ; then
    cat /mnt/openssh_id.pub >> /root/.ssh/authorized_keys
    chmod 0600 /root/.ssh/authorized_keys
fi
EOL

cat <<EOL >> /etc/ssh/sshd_config
UseDNS  no
PermitRootLogin without-password
EOL

%end

%post
# pv-grub stuff
sed -i 's/(hd0,0)/(hd0)/g' /boot/grub/grub.conf
sed -i 's/root=/dev/sda1/root=LABEL=\//g' /boot/grub/grub.conf
cp /boot/grub/grub.conf /boot/grub/menu.lst
%end
