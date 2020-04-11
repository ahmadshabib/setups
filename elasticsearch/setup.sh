#!/usr/bin/env bash
set -v


VERSION="7.6.2"
HEAPSIZE="1g"

OPTS=`getopt -o v:s:h --long version:heapsize:help -n 'parse-options' -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

USAGE="[options]\n\nOptions:\n
\t-h Help show this message and exit\n
\t-v|--version Version   Version of elastic search to download Default 7.6.2 (Optional)\n
\t-s|--heapSize HEAPSIZE   heapsize of the JVM that is being used by elasticsearch default is 1g ex:512m (Optional)\n
"

while true;
do
  case "$1" in
  -v|--version)  VERSION=$2; shift 2 ;;
  -s|--heapSize)  HEAPSIZE=$2; shift 2 ;;
  -h|--help)   printf "$USAGE" 1>&2
       exit 0;;
  -- ) shift; break ;;
  * ) break ;;
  \?)  printf "$USAGE" 1>&2
       exit 22;;
  esac
done

sudo apt-get update

echo "Installing java"
# In case java is not there
sudo apt-get install default-jdk -y
echo "============================================================"

echo "Installing Elastic search"
#Installing elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${VERSION}-amd64.deb
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${VERSION}-amd64.deb.sha512
shasum -a 512 -c elasticsearch-${VERSION}-amd64.deb.sha512
sudo dpkg -i elasticsearch-${VERSION}-amd64.deb
echo "============================================================"


# Enable elasticsearch as a service
echo "Enable elasticsearch"
sudo update-rc.d elasticsearch defaults 95 10
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
echo "============================================================"

## Increase the number of files Elasticsearch to avoid “Too many open sockets” error
echo "Increase the number of elasticsearch files"
sudo tee -a /etc/security/limits.conf > /dev/null <<EOT
elasticsearch soft nofile 65536\n
elasticsearch hard nofile 65536\n
elasticsearch soft memlock unlimited\n
elasticsearch hard memlock unlimited
EOT
echo "============================================================"

## Remove the elasticsearch memory limit.
echo "Remove memory limit"
ELASTICSEARCH_SF="/usr/lib/systemd/system/elasticsearch.service"
sudo grep -q '# LimitMEMLOCK=infinity' ${ELASTICSEARCH_SF} && sudo sed 's/# LimitMEMLOCK=infinity/LimitMEMLOCK=infinity/' ${ELASTICSEARCH_SF} || sudo tee -a ${ELASTICSEARCH_SF} > /dev/null <<EOT
LimitMEMLOCK=infinity
EOT
echo "============================================================"

## Enable memory lock in Elasticsearch
echo "Enable Memory lock"
ELASTICSEARCH_CONF="/etc/elasticsearch/elasticsearch.yml"
sudo grep -q '# bootstrap.memory_lock: true' ${ELASTICSEARCH_CONF} && sudo sed 's/# bootstrap.memory_lock: true/bootstrap.memory_lock: true/' ${ELASTICSEARCH_CONF} || sudo tee -a ${ELASTICSEARCH_CONF} > /dev/null <<EOT
bootstrap.memory_lock: true
EOT
echo "============================================================"

## Change the heapsize of JVM that is being used by elastic search
echo "Changing VM Heapsize"
echo ${HEAPSIZE}
sudo sed -i "s/-Xms.*/-Xms$HEAPSIZE/" /etc/elasticsearch/jvm.options
sudo sed -i "s/-Xmx.*/-Xmx$HEAPSIZE/" /etc/elasticsearch/jvm.options
echo "============================================================"

##
echo "Restart the daemon"
sudo systemctl daemon-reload
sudo service elasticsearch restart
echo "============================================================"

#Testing purpose
sudo curl "localhost:9200/_nodes/process?pretty"