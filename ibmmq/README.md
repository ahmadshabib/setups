# IBM® MQ ec2 https
How to setup [IBM® MQ 9](https://www.ibm.com/support/knowledgecenter/SSFKSJ_9.1.0/com.ibm.mq.pro.doc/q001020_.htm) on EC2 (Amazon Linux 2 AMI) with https access.

This Script would only create the Queue manager while the setup of the IBM MQ Queue channel and queues
Should be done after connecting to EC2 instance or through browser.

## Create an EC2 instance
* open AWS Console in browser
* go to EC2
* select **Launch Instance**
* select **Amazon Linux 2 AMI**
* select **t2.micro** (I use **t2.small** to get more memory for my greedy build)
* select **Configure Instance Details**
* tick **Enable termination protection**
* select **Add Storage**
* change size to preferred (I use 100GB for our large enterprise builds)
* select **Add Tags**
* select **Configure Security Group**
* add rule *HTTPS*
* add rule *Custom TCP for port 9443*
* add rule *Custom TCP for port 1441*
* select **Review and launch**
* select a key pair
* select **Launch Instance**
* In EC2 go to instances, once instance running then select instance and click **Connect**
* copy ssh command in the example to terminal and run (you'll need your referenced key file present in that directory)

## Deploy IBM® MQ
Login to the instance using the ssh command mentioned above. Then run:
```bash
wget --no-cache https://raw.githubusercontent.com/ahmadshabib/setups/master/ibmmq/setup.sh && chmod +x setup.sh
```
Now run setup with -m flag to specify the Queue manager name(Default is QM1):
```bash
./setup.sh
```
If you want to change the ports edit the file `setup.sh` and edit the top block of parameters with the values you want.
```bash
# I use vi, you might use nano or anything else you're comfortable with
vi setup.sh
```

Now go to https://your_instance:9443 in the browser and put `admin` as username and `passw0rd` as administration password in the browser. If the browser times out go to the same url again (make sure it's https). That's it!
If you want to access the IBM MQ through commandline:
* Run `sudo docker ps`
* Using the name of the docker instance run `docker exec -it $name_of_inctance /bin/bash`