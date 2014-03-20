#!/bin/sh
#
# Generate Nagios/Icinga host files from another environment's host file.
# Assumes valid DNS services, will skip hosts without forward records.
# Assumes host lookup of short DNS name will result in single IP and FQDN.
#
# Input (dev):
# define host{
#   host_name                       mc01.dev.sample.org
#   address                         10.1.2.3
# }
#
# Output (prod):
# define host {
#   host_name                       mc01.prod.sample.org
#   address                         10.2.2.3
#   use                             sample_host
# }
#

for HN in `awk '/host_name/ { print $2 }' hosts.cfg | cut -f1 -d.`; do
        host ${HN} | awk '{ print $1, $4 }' | grep -v found
done > out

awk '{ printf "define host {\n\
\thost_name\t\t\t%s\n\
\taddress\t\t\t\t%s\n\
\tuse\t\t\t\tsample_host\n\
}\n\n", $1, $2 }' out

# EOF

