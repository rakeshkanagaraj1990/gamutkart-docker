#!/bin/sh -e
set -x 

NAME="gamutgurus"
[ -z "$1" ] && { echo "Please provide the buildnumber that to be deployed." ; exit 1; }

# Stopping & Removing Gamutgurus Container if Exist
CONTAINER_NAME=$(sudo docker ps -a --format "{{.Names}}" --filter "name=$NAME")
CONTAINER_STATUS=$(sudo docker ps -a --format "{{.Names}} {{.Status}}" --filter "name=$NAME" | awk '{print $2}')

if [ "$CONTAINER_NAME" = "gamutgurus" ] && [ "$CONTAINER_STATUS" = "Up" ] || [ "$CONTAINER_STATUS" = "Exited" ];
then
  sudo docker rm -f "$CONTAINER_NAME"
  echo "The $CONTAINER_NAME container which status was $CONTAINER_STATUS has been successfully removed"
else
  echo "No such docker container named gamutgurus found in the server"
fi

# Removing Gamutgurus Images if Exist

IMAGE_NAME=$(sudo docker images --format "{{.Repository}}" --filter reference=rkdockerking/gamutkart)
IMAGE_TAG=$(sudo docker images --format "{{.Tag}}" --filter reference=rkdockerking/gamutkart)

if [ "$IMAGE_NAME" = "rkdockerking/gamutkart" ];
then
  sudo docker rmi "$IMAGE_NAME":"$IMAGE_TAG"
  echo "Successfully removed $IMAGE_NAME:$IMAGE_TAG"
else
  echo "No such docker images named rkdockerking/gamutkart found in the server"
fi

# Deploying latest image
sudo docker run -d --name "$NAME" -p 8090:8080 rkdockerking/gamutkart:"$1"
COMMAND_STATUS=$?
sleep 30
NEW_CONTAINER_STATUS=$(sudo docker ps -a --format "{{.Names}} {{.Status}}" --filter "name=$NAME" | awk '{print $2}')

if [ "$COMMAND_STATUS" = "0" ] && [ "$NEW_CONTAINER_STATUS" = "Up" ];
then
  echo "The lastest build $1 of $NAME has been successfully deployed"
else
  echo "The deployment for build $1 failed "
fi
