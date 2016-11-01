#!/bin/sh
#
# Copyright 2016 Cloudera Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
#
# Look at commonly tweaked RHEL settings relevant to Hadoop.
# Retrieval only, up to user to determine appropriateness.
#

# system and OS flags
echo "System: $(uname -a)"
if [ -f /etc/redhat-release ] ; then
  echo ; echo "OS: $(cat /etc/redhat-release)"
  grep 7.2 /etc/redhat-release
  if [ "$?" = "0" ] ; then
    RHEL7=1
  fi
else
  echo 'Not RHEL, exiting.'
  exit 1
fi

# kernel options
echo ; echo "Swappiness (current): $(cat /proc/sys/vm/swappiness)"
echo ; echo "Swappiness (boot): $(grep swappiness /etc/sysctl.conf)"
echo ; echo "Transparent Huge Pages (enabled): $(cat /sys/kernel/mm/transparent_hugepage/enabled)"
echo ; echo "Transparent Huge Pages (defrag): $(cat /sys/kernel/mm/transparent_hugepage/defrag)"

# storage
echo ; echo 'Mounts'
mount | grep -v cgroup
echo ; echo 'Volume Sizing'
df -h

# iptables
echo
if [ $RHEL7 ] ; then
  systemctl list-unit-files --type=service | grep -E '(firewalld|iptables|ip6tables)'
else
  /sbin/chkconfig --list iptables
  /sbin/chkconfig --list ip6tables
fi

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
