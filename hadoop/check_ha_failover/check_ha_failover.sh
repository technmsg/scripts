#!/bin/sh
#
# Copyright 2014 Cloudera Inc.
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
# Simple script to detect whether there's been a failover
# event with an HDFS NameNode or YARN Resource Manager. 
#

# path to status file
LAST_ACTIVE_FILE='last_active.txt'

# NN or RM IDs -- not usually hostnames
NN1=namenode1
NN2=namenode2

CHECK="hdfs haadmin -getServiceState"
#CHECK="yarn rmadmin -getServiceState"

# the check hinges on knowing what the last active master was...
if [ -f ${LAST_ACTIVE_FILE} ] ; then
  LAST_ACTIVE=$(cat $LAST_ACTIVE_FILE)
  echo "INFO: Last active = ${LAST_ACTIVE}."

  # retrieve each master status
  NN1_STATUS=$($CHECK $NN1)
  NN2_STATUS=$($CHECK $NN2)

  # testing status
#  NN1_STATUS=active
#  NN2_STATUS=standby

  echo "INFO: ${NN1} = ${NN1_STATUS}"
  echo "INFO: ${NN2} = ${NN2_STATUS}"
  
  # beware split-brain
  if [ $NN1_STATUS = $NN2_STATUS ] ; then
    echo "ERROR: Possible split brain, both ${NN1_STATUS}."
    exit 1
  fi

  # determine current active
  if [ $NN1_STATUS = 'active' ] ; then
    CURR_ACTIVE=${NN1}
  elif [ $NN2_STATUS = 'active' ] ; then
    CURR_ACTIVE=${NN2}
  fi
  echo "INFO: Currently active = ${CURR_ACTIVE}"

  # determine whether there was a failover event
  if [ ${CURR_ACTIVE} = ${LAST_ACTIVE} ] ; then
    echo "INFO: No change."
    exit 0
  else
    echo "WARN: Failover detected from ${LAST_ACTIVE} to ${CURR_ACTIVE}"

    # optional: update the last_active file
    echo ${CURR_ACTIVE} > ${LAST_ACTIVE_FILE}
    exit 1
  fi
  
else
  echo "INFO: No status file ${LAST_ACTIVE_FILE}."
  exit 2
fi

# EOF
