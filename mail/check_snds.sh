#!/bin/bash
#
# Retrieve Microsoft Smart Network Data Service (SNDS) data
#

if [ -z $1 ] ; then
  echo "Usage: $0 <key>"
  exit 1
fi

key=$1

declare -A urls
urls[data]="https://postmaster.live.com/snds/data.aspx?key=${key}"
urls[ipStatus]="https://postmaster.live.com/snds/ipStatus.aspx?key=${key}"

for i in "${!urls[@]}"
do
  tmp=$(mktemp)
  curl -s "${urls[$i]}" > "$tmp"

  if [ -s "$tmp" ] ; then
    echo "$i"
    echo '---'
    cat "$tmp"
    echo
  fi

  rm "$tmp"
done

# EOF
