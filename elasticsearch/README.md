# IBM® MQ ec2 https
How to setup [Elastic Search 7.6.2](https://www.elastic.co/guide/en/elasticsearch/reference/current/release-notes-7.6.2.html) on EC2 (Ubuntu Server 18.04 LTS).

This Script would only create the elasticsearch service and get it up. 
Should be done after connecting to EC2 instance or through browser.

## Create an EC2 instance
* open AWS Console in browser
* go to EC2
* select **Launch Instance**
* select **Ubuntu Server 18.04 LTS**
* select **t2.micro** (I use **t2.small** to get more memory for my greedy build)
* select **Configure Instance Details**
* tick **Enable termination protection**
* select **Add Storage**
* change size to preferred (I use 100GB for our large enterprise builds)
* select **Add Tags**
* select **Configure Security Group**
* add rule *HTTPS*
* add rule *Custom TCP for port 9200*
* select **Review and launch**
* select a key pair
* select **Launch Instance**
* In EC2 go to instances, once instance running then select instance and click **Connect**
* copy ssh command in the example to terminal and run (you'll need your referenced key file present in that directory)

## Deploy Elasticsearch
Login to the instance using the ssh command mentioned above. Then run:
```bash
wget --no-cache https://raw.githubusercontent.com/ahmadshabib/setups/master/elasticsearch/setup.sh && chmod +x setup.sh
```
Now run setup with:
```bash
./setup.sh
```
For more info about the available options run:
```bash
./setup.sh -h
```

If you want to change the ports edit the file `setup.sh` and edit the top block of parameters with the values you want.
```bash
# I use vi, you might use nano or anything else you're comfortable with
vi setup.sh
```

In order to test go your bash terminal and run 
`curl -X GET "http://${IP_OF_YOUR_INSTANCE}:9200/?pretty"`
