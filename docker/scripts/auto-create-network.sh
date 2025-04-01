#!/bin/bash

# Name of the file containing network names
file="../networks.yml"

# Read file and extract network names into an array
network_names=($(grep -oP '.*-nw:' $file | tr -d ' ' | tr -d ':'))

counter=1;
# Loop through the network names and create Docker networks
for network_name in "${network_names[@]}"
do
  # Create a Docker network with a default driver
  docker network create --subnet=172.16.$counter.0/24 ${network_name}

  counter=$((counter+1))
done