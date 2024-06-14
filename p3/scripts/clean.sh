#!/bin/bash

echo "Starting cleanup process"

# Stop and remove the Docker container
echo "Stopping and removing Docker container"
docker stop mycontainer
docker rm mycontainer

# Delete the K3s cluster
echo "Deleting K3s cluster"
k3d cluster delete mycluster

# Kill the port forwarding processes
echo "Killing port forwarding processes"
pkill -f "run.sh"

echo "Cleanup process completed"