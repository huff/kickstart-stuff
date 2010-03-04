# Kickstart file to build Fedora Amazon EC2 image
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
part /boot --size 100 --fstype ext3 --ondisk hda
part / --size 1024 --fstype ext3 --ondisk hda

#
# Repositories
#
# To compose against the current release tree, use the following "repo" (enabled by default)
#repo --name=released --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-12&arch=$basearch
# To include updates, use the following "repo" (enabled by default)
#repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f12&arch=$basearch

repo --name="rhel54-x86_64" --baseurl=http://porkchop.devel.redhat.com/released/RHEL-5-Server/U4/x86_64/os/Server/

# To compose against rawhide, use the following "repo" (disabled by default)
#repo --name=rawhide --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=rawhide&arch=$basearch

# To compose against local trees, (edit and) use:
#repo --name=f10 --baseurl=http://localrepo/fedora/releases/12/Everything/$basearch/os/
#repo --name=f10-updates --baseurl=http://localrepo/fedora/updates/12/$basearch/

#
# Add all the packages after the base packages
#
%packages --excludedocs
@core
@base
%end

#
# Add custom post scripts after the base post.
#
%post
# Do Ec2 stuff
%end

