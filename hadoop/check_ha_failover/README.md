# check_ha_failover

From a customer question about Hadoop, "is these a way to alert us of failover events?"

Beyond parsing logs, not exactly. The `-getServiceState` commands will provide an "active" or "standby" value:

	hdfs haadmin -getServiceState <nn>
	yarn rmadmin -getServiceState <rm>

[The check_ha_failover script](https://github.com/technmsg/scripts/blob/master/hadoop/check_ha_failover/check_ha_failover.sh) attempts to provide a simple detection method that could be used by a monitoring platform to alert operations staff, perhaps through Nagios.
