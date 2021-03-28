#!/bin/bash

#####################################
# COLORS BLOCK
RED="\\033[1;31m"
BLUE="\\033[1;34m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
RED="\033[41m\033[1;33m"
NC="\033[0m\n" # No Color

#####################################
# SHOW HELP
show_help() {
  echo "-----------------------------------------------------------------------"
  echo "                      Available commands                              -"
  echo "-----------------------------------------------------------------------"
  echo -e -n "$BLUE"
  echo "   > build - To build the Docker image"
  echo "   > push - To push container"
  echo "   > pull - To pull container"
  echo "   > install - To execute full install at once"
  echo "   > stop - To stop container"
  echo "   > start - To start container"
  echo "   > remove - Remove container"
  echo "   > help - Display this help"
  echo -e -n "$NC"
  echo "-----------------------------------------------------------------------"
}

if [ "$1" == "" ]; then
    show_help
    exit 1
fi

#####################################
# CHECK SUDO

function check_sudo () {
  if [ "$(id -u)" != "0" ]; then
    printf "$RED Sorry, you are not root.$NC"
    exit 1
  fi
}

#####################################
# Load environment variables
export $(cat .env | xargs)

#####################################
# LOG MESSAGE
log() {
  printf "$BLUE > $1 $NORMAL"
}

#####################################
# ERROR MESSAGE
error() {
  printf ""
  printf "$RED >>> ERROR - $1$NORMAL"
}

#####################################
# REMOVE CONTAINER
remove() {
  log "DELETE $CONTAINER_NAME"

  docker stop $CONTAINER_NAME
  docker rm --force $CONTAINER_NAME
  docker rmi --force $CONTAINER_NAME

  docker stop $DOCKER_ID_USER/$CONTAINER_NAME
  docker rm --force $DOCKER_ID_USER/$CONTAINER_NAME
  docker rmi --force $DOCKER_ID_USER/$CONTAINER_NAME
}

#####################################
# STOP CONTAINER
stop() {
  log "STOP $CONTAINER_NAME"

  docker stop $CONTAINER_NAME
}

#####################################
# START CONTAINER
start() {
  log "START $CONTAINER_NAME"

  docker start $CONTAINER_NAME
}

#####################################
# BUILD CONTAINER
build() {
  log "BUILD $CONTAINER_NAME"
  DOCKERFILE=$(pwd)/Dockerfile
  # Build Container
  docker build --rm --force-rm --no-cache -f $DOCKERFILE -t $CONTAINER_NAME .

  if [ $? -eq 0 ]; then
    log "OK"
  else
    error "FAIL"
    exit 1
  fi
}

#####################################
# PUSH CONTAINER
push() {
  log "PUSH $CONTAINER_NAME"
  docker tag $CONTAINER_NAME $DOCKER_ID_USER/$CONTAINER_NAME:$TAG
  docker push $DOCKER_ID_USER/$CONTAINER_NAME:$TAG
}

#####################################
# PULL CONTAINER
pull() {
  log "PULL $CONTAINER_NAME"
  docker pull $DOCKER_ID_USER/$CONTAINER_NAME:$TAG
}

#####################################
# INSTAL/UPGRADE CONTAINER
install() {

  if [ ! -z "$NETWORK_NAME" ]; then
    if [ ! "$(docker network ls | grep $NETWORK_NAME)" ]; then
      log "Creating '$NETWORK_NAME' network ..."
      docker network create $NETWORK_NAME
    else
      log "'$NETWORK_NAME' network exists."
    fi
  fi

  if [ ! "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=$CONTAINER_NAME)" ]; then
      # cleanup
      log "DELETE $CONTAINER_NAME"
      docker rm $CONTAINER_NAME
    fi
    log "INSTALL $CONTAINER_NAME"
    docker run --name=$CONTAINER_NAME \
               -v /etc/localtime:/etc/localtime:ro \
               -dit $CONTAINER_NAME
  else
    pull
    remove
    run
  fi

  if [ $? -eq 0 ]; then
    log "OK"
  else
    error "FAIL"
    exit 1
  fi


}

log "START\n"
$1
log "FINISH\n"

