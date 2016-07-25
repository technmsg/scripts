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
# Simple script to detect whether Cloudera Manager configuration has
# changed over time. Retrieves JSON config via API. If previous output
# exists will compare for changes. Most likely run from cron.
#
# Exit codes: 0 for no change, 2 for change, 1 for error
#

#
# Set the following
#

# Work directory, must persist between runs
WORK_DIR='work'

# CM hostname and port
CM_HOST='cm.cluster.example.com:7180'

# CM username and password
CM_USER='admin'
CM_PASS='admin'

# Recipient of email; leave uncommented to disable email.
#RECIP='your-cm-admin@example.com'


#
# Leave the rest alone.
#

CURL="curl -k -X GET -u ${CM_USER}:${CM_PASS} http://${CM_HOST}/api/v5/cm/deployment"
OLD_CFG=${WORK_DIR}/old.json
NEW_CFG=${WORK_DIR}/new.json
CHG_CFG=${WORK_DIR}/delta.txt

# Retrieve JSON configuration of CM via the API
retrieve_config () {
  echo "Retrieving configuration via CM API..."
  ${CURL} > ${NEW_CFG}
  #sed -i '/timestamp/d' ${NEW_CFG}   # GNU sed
  strip_timestamp $NEW_CFG            # non-GNU sed
}

# Remove the timestamp line since it'll always be different
strip_timestamp () {
  if [ -z "$1" ] ; then
    echo "strip_timestamp: no function passed!"
  else
    if [ -e "$1" ] ; then
      tmp=$(mktemp /tmp/cm_api_cfg_checker.XXXXXX)
      sed '/timestamp/d' "$1" > "$tmp"
      mv "${tmp}" "$1"
    else
      echo "$1 does not exit"
    fi
  fi
}

# Stop if there's no working directory
if [ ! -d ${WORK_DIR} ] ; then
  echo "Work dir does not exist." && exit 1
fi 

# first run, just grab the config
if [ ! -e ${NEW_CFG} ] ; then
  retrieve_config
  echo "First run, nothing to compare. Exiting."
  exit 0
fi

# rotate now-old cfg
mv  ${NEW_CFG} ${OLD_CFG}

# retrieve new cfg
retrieve_config

# compare to old cfg
echo Comparing to old config
diff ${OLD_CFG} ${NEW_CFG} > ${CHG_CFG}

# if result, email result to something
if [ -s "${CHG_CFG}" ] ; then
  echo "There were changes on ${CM_HOST}!" ; echo ; cat "${CHG_CFG}"

  if [ -z "${RECIP}" ] ; then
    mail -s "Changes to CM configuration on ${CM_HOST}" "${RECIP}" < "${CHG_CFG}"
  fi
  exit 2
else
  echo "No changes."
  exit 0
fi

# EOF
