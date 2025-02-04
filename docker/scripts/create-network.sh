#!/bin/bash

# Ask user for name
read -p "Please enter the name (XXXXXX-nw): " name

# Ask user for subnet
read -p "Please enter the index (172.16.XX.0/24): " index

# Create a docker network with default driver with user inputs
docker network create --subnet=172.16.$index.0/24 ${name}-nw
