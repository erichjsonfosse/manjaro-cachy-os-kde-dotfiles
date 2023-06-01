#!/bin/bash

echo "Enabling snap service..."

startServiceAndWaitUntilItIsRunning "snapd.socket" 5
startServiceAndWaitUntilItIsRunning "snapd.service" 5
