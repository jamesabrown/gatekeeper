# Gatekeeper
<img src="https://travis-ci.org/jamesabrown/gatekeeper.svg?branch=master"/>
<a href='https://coveralls.io/github/jamesabrown/gatekeeper?branch=master'><img src='https://coveralls.io/repos/github/jamesabrown/gatekeeper/badge.svg?branch=master' alt='Coverage Status' /></a>

Gatekeeper is an API to allow dynamic management of an AWS security group. 

* You can have an IP added to the security group with the whitelist endpoint on the API. 
 http://example.com/whitelist/<ip_address>
* You can then in turn hit the /expire/ endpoint to expire any entries older than 48 hours.
 http://example.com/expire/
* The HTTP_KEY header is required to match the GK_AUTH_TOKEN environment variable for authentication. 

## Configuration
Gatekeeper requires several environment variables in order to properly authenticate and funciton. These are defined in env.list.
* Copy env.list.sample to env.list and populate with correct values

## Run Gatekeeper
Gatekeeper has a Docker container built to run the app easily with the following commands

```shell
docker pull jamesabrown/gatekeeper
docker run -d -p 80:4567 --env-file ./env.list jamesabrown/gatekeeper
```

