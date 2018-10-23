Base image that contains the Postfix/OpenDKIM services (based on the Alpine Linux)
==============

run postfix/opendkim as docker services.

## Requirement
+ Docker 18.2 and higher

## Pull image from DockerHub

```bash
$ sudo docker pull smugljanka/postfix-relay-opendkim
```

## Usage 
1. Change the following stack parameters in mta-stack.yml 
   `
   # You can specify the list of "trusted" network addresses, separated by commas. Default
   # local network 127.0.0.0/8 will be added automatically.
   # Or leave this variable empty or comment out to let Postfix do it for you
   POSTFIX_NETWORKS='127.0.0.0/8,...',
   # Set the internet hostname of this mail system.
   POSTFIX_HOSTNAME=mx.<YOUR_DOMAIN>,
   # Set the internet domain name of this mail system.
   POSTFIX_DOMAIN=<YOUR_DOMAIN>,
   # Set DKIM selector name that identified your public DKIM Key details of the Domain
   DKIM_SELECTOR=<YOUR_DKIM_SELECTOR>,
   # Set a regexp map to define trusted hosts into the postfix networks.
   # All client connections to the mail-dkim service will be verified in according to
   # the provided regexp map
   POSTFIX_NETWORKS_REGEXP_MAP=10.*.*.*`
   
2. Generate RSA keys for your domain
```bash
 $ sudo openssl rsa -in your.domain.com.priv -pubout >your.domain.com.pub
```
3. Setup your DNS - create DKIM record in your domain - add the public key created above
4. Change "domain-dkim-key" secret - set path to your your.domain.com.priv key
```bash
   secrets:
     domain-dkim-key:
       file: /path/to/your/rsa-keys/your.domain.com.priv
```
4. Create docker stack
```bash
$ sudo docker stack deploy -c ./mta-stack.yml <STACK_NAME>
```

## Note
+ Uncomment port mapping in "mail-relay" service if you want to permit connections from outside
+ The mentioned services are used as internal MTA by web application
+ The "app-net" network is external, it was created outside the stack

## Reference
+ [Postfix Howto](http://www.postfix.org/)
+ [OpenDKIM Howto](http://opendkim.org/)
+ TBD

