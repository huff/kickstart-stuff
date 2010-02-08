# fedora-cloud-minimal.ks
#
# Defines a minimal Eucalyptus/EC2 installation

lang en_US.UTF-8
keyboard us
timezone US/Eastern --utc
auth --useshadow --enablemd5
selinux --enforcing
firewall --enabled
network --bootproto=dhcp --device=eth0 --onboot=on
part / --size 4096 --fstype ext4 --ondisk=ami-fedora12-i386-base

repo --name=fedora --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-12&arch=$basearch
repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f12&arch=$basearch

%packages
@core
acpid
chkconfig
irqbalance
kernel
man-pages
openssh-server
pinfo
readahead
tar
unzip
zip
%end

%post
# fix fstab
cat >> /etc/fstab << EOF
/dev/sda2 /mnt auto defaults 0 2
/dev/sda3 swap swap defaults 0 0
EOF

# save a little bit of space at least...
#rm -f /boot/vmlinuz*
#rm -f /boot/initrd*
%end

