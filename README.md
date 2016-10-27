# Gatekeeper
Gatekeeper is an API to allow dynamic management of an AWS security group. 

## Configuration
Gatekeeper requires several environment variables in order to properly authenticate and funciton. These are defined in env.list.
* Copy env.list.sample to env.list and populate with correct values

## Run Gatekeeper
Gatekeeper has a Docker container built to run the app easily with the following commands

```shell
docker pull jameabrown/gatekeeper
docker run -d -p 80:4567 --env-file ./env.list jb/gatekeeper
```

