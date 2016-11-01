#!/bin/sh

# Look at commonly tweaked RHEL settings relevant to Hadoop.
# Retrieval only, up to user to determine appropriateness.

echo "System: $(uname -a)"
if [ -f /etc/redhat-release ] ; then
  echo ; echo "OS: $(cat /etc/redhat-release)"
else
  echo 'Not RHEL, exiting.'
  exit 1
fi

# kernel options
echo ; echo "Swappiness (current): $(cat /proc/sys/vm/swappiness)"
echo ; echo "Swappiness (boot): $(grep swappiness /etc/sysctl.conf)"
echo ; echo "Transparent Huge Pages (enabled): $(cat /sys/kernel/mm/redhat_transparent_hugepage/enabled)"
echo ; echo "Transparent Huge Pages (defrag): $(cat /sys/kernel/mm/redhat_transparent_hugepage/defrag)"

# storage
echo ; echo 'Mounts'
mount
echo ; echo 'Volume Sizing'
df -h

# iptables
echo 
/sbin/chkconfig --list iptables
/sbin/chkconfig --list ip6tables

# IPv6
echo ; echo 'IPv6 (current)'
/sbin/ip addr
echo ; echo 'IPv6 (boot)'
grep ipv6 /etc/sysctl.conf

# SELinux

echo ; sestatus
echo ; echo 'SELinux (boot)'
grep -v ^# /etc/sysconfig/selinux | grep -v ^$

# EOF
