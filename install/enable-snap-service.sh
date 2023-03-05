#!/bin/bash

echo "Enabling snap service..."

# Enabling Service
systemctl enable --now snapd.socket
systemctl enable --now snapd.service

waitUntilServiceIsRunning "snapd.socket" 5
waitUntilServiceIsRunning "snapd.service" 5
