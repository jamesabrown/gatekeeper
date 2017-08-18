# Gatekeeper
![Coverage Status](https://travis-ci.org/jamesabrown/gatekeeper.svg?branch=master) [![Coverage Status](https://coveralls.io/repos/github/jamesabrown/gatekeeper/badge.svg?branch=master)](https://coveralls.io/github/jamesabrown/gatekeeper?branch=master)

Gatekeeper is an API to allow dynamic management of an AWS security group. 

* You can have an IP added to the security group with the whitelist endpoint on the API. 
 http://example.com/whitelist
* You can then in turn hit the /expire endpoint to expire any entries older than 48 hours.
 http://example.com/expire
* The HTTP_KEY header is required to match the GK_AUTH_TOKEN environment variable for authentication. 

## Configuration
Gatekeeper requires several environment variables in order to properly authenticate and funciton. These are defined in env.list.
* Copy env.list.sample to env.list and populate with correct values

### Optional parameters
If the environment variable `ALLOWED_COUNTRIES` is set, Gatekeeper will only allow countries defined within that variable.
`ALLOWED_COUNTRIES` is expected to have values arranged in the following way: `United States,Canada,Brazil`

## Run Gatekeeper
Gatekeeper has a Docker container built to run the app easily with the following commands

```shell
docker pull jamesabrown/gatekeeper
docker run -d -p 80:4567 --env-file ./env.list jamesabrown/gatekeeper
```

