
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Cassandra Tombstone Dump Incident
---

A Cassandra tombstone dump incident refers to a situation in which a database table in Cassandra has too many tombstones (deleted data markers), causing performance issues and potentially leading to data loss. This type of incident requires immediate attention from a software engineer as it can negatively impact the overall system's stability and availability. The incident may be caused by a variety of factors, such as a misconfigured garbage collector or an application that is generating too many tombstones.

### Parameters
```shell
# Environment Variables

export KEYSPACE="PLACEHOLDER"

export TABLE="PLACEHOLDER"

export PARAMETER="PLACEHOLDER"

export GC_NAME="PLACEHOLDER"

export GC_OPTIONS="PLACEHOLDER"

export PATH_TO_CASSANDRA_HOME_DIRECTORY="PLACEHOLDER"

```

## Debug

### Check Cassandra's status
```shell
nodetool status
```

### Check for any errors in the Cassandra system log
```shell
sudo tail -f /var/log/cassandra/system.log | grep ERROR
```

### Check if any tombstone threshold has been exceeded
```shell
nodetool tablestats ${KEYSPACE}.${TABLE} | grep "Tombstone cells"
```

### Check the number of tombstones per partition
```shell
nodetool cfstats ${KEYSPACE}.${TABLE} | grep tombstones
```

### Check the size of the tombstone files on disk
```shell
sudo find /var/lib/cassandra/data/${KEYSPACE}/${TABLE} -name "*-Data.db" -exec ls -lh {} \; | awk '{print $5, $9}'
```

### Check the garbage collector logs for any errors
```shell
sudo tail -f /var/log/cassandra/gc.log | grep ERROR
```

### Check Cassandra's configuration file for any misconfigurations
```shell
cat /etc/cassandra/cassandra.yaml | grep ${PARAMETER}
```

### Check if any nodes in the Cassandra cluster are down
```shell
nodetool status | grep DN
```

### Misconfigured garbage collector: If the garbage collector in Cassandra is misconfigured, it may not be cleaning up tombstones effectively, leading to an accumulation of tombstones that can impact performance and stability.
```shell


#!/bin/bash



# Set the Cassandra home directory path

CASSANDRA_HOME="PLACEHOLDER"



# Check the garbage collector settings in the Cassandra configuration file

gc_type=$(grep "^#.*-XX:.*GC" $CASSANDRA_HOME/conf/cassandra-env.sh | awk '{print $2}')

if [[ "$gc_type" == "-XX:+UseG1GC" ]]; then

  echo "The garbage collector is set to G1GC, which is recommended for Cassandra."

else

  echo "The garbage collector is set to $gc_type, which may not be optimal for Cassandra."

fi



# Check the garbage collector log for any issues

gc_log=$(grep "^#.*-Xloggc" $CASSANDRA_HOME/conf/cassandra-env.sh | awk '{print $2}')

if [[ -f "$gc_log" ]]; then

  last_gc=$(grep "Full GC" $gc_log | tail -1)

  if [[ -n "$last_gc" ]]; then

    echo "The garbage collector logged a Full GC event at: $last_gc"

  else

    echo "No Full GC events were logged by the garbage collector."

  fi

else

  echo "The garbage collector log file could not be found."

fi


```

## Repair

### Set the path to the Cassandra configuration file
```shell
CASSANDRA_CONF="PLACEHOLDER"
```

### Set the name of the garbage collector to use
```shell
GC_NAME=${GC_NAME}
```

### Set the options for the garbage collector
```shell
GC_OPTIONS=${GC_OPTIONS}
```

### Backup the original configuration file
```shell
cp $CASSANDRA_CONF $CASSANDRA_CONF.orig
```

### Modify the garbage collector settings in the configuration file
```shell
sed -i "s/-XX:+UseG1GC/-XX:+Use$GC_NAME $GC_OPTIONS/g" $CASSANDRA_CONF
```

### Restart the Cassandra service to apply the changes
```shell
systemctl restart cassandra
```