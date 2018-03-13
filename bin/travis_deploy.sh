#!/bin/bash
set -e

docker login -u $DOCKER_LOGIN_USERNAME -p $DOCKER_LOGIN_PASSWORD
if [[ -n $TRAVIS_TAG ]]
then
  echo "Pushing tag $TRAVIS_TAG..." &&
  docker tag $DOCKER_IMAGE:$DOCKER_TAG $DOCKER_IMAGE:$TRAVIS_TAG &&
  docker push $DOCKER_IMAGE:$TRAVIS_TAG
fi
if [[ $TRAVIS_BRANCH == "master" ]]
then
  docker tag $DOCKER_IMAGE:$DOCKER_TAG $DOCKER_IMAGE:latest &&
  docker push $DOCKER_IMAGE:latest &&
  docker push $DOCKER_IMAGE:$TRAVIS_TAG
fi
