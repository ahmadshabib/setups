#!/usr/bin/env bash

QUEUE_MANAGER_NAME=QM1

OPTS=`getopt -o m: --long queuemanager: -n 'parse-options' -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true;
do
  case "$1" in
  -m|--queuemanager)  QUEUE_MANAGER_NAME=$2; shift 2 ;;
  -h|--help)   printf "$USAGE" 1>&2
       exit 0;;
  -- ) shift; break ;;
  * ) break ;;
  \?)  printf "$USAGE" 1>&2
       exit 22;;
  esac
done

sudo yum update -y
# Install docker
sudo yum install docker -y

#Start docker
sudo service docker start

#Display, read and make sure you understand and are OK with IBM MQ license
sudo docker run --env LICENSE=view ibmcom/mq:9

#Run the docker instance publishing on both 1414 and 9443 ports.
sudo docker run --env LICENSE=accept --env MQ_QMGR_NAME=${QUEUE_MANAGER_NAME} --volume /var/example:/mnt/mqm --publish 1414:1414 --publish 9443:9443 --detach ibmcom/mq:9