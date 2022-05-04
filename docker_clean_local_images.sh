#!/bin/bash
set -e
#set -v
#set -x
whoami
id
df -h

REPOSITORIES=$( docker images --format '{{.Repository}}' | sort -u )


NUM_OF_IMAGES_TO_KEEP=20

for repo in $REPOSITORIES
do
   echo Repository: $repo
   if [[ "$repo" == "nexus"* ]];
   then
     echo "handling this repository image"
     IMAGES=$( docker image ls --filter=reference=$repo --format '{{.ID}} {{.Repository}}:{{.Tag}} {{.CreatedAt}} {{.Size}}' | awk 'NR>'$NUM_OF_IMAGES_TO_KEEP'' )
     NUM_OF_IMAGES=$( echo "$IMAGES" | wc -l )
     NUM_OF_BYTES=$( echo "$IMAGES" | wc -m )
     if [[ $NUM_OF_BYTES -gt 1 ]];
     then
     	echo "list of images ($NUM_OF_IMAGES) to be removed: (without a force flag since most probably one of the images is a base image)"
        echo "$IMAGES"
        IMAGES_ID=$( echo "$IMAGES" | cut -d' ' -f1 )
        docker rmi "$IMAGES_ID"
     else
        echo "no images for this repo that are canidates for removal..."
     fi    
    
   fi
done


df -h
