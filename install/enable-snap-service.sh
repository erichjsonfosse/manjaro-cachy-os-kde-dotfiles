#!/bin/bash

echo "Enabling snap service..."

# Enabling Service
systemctl enable --now snapd.socket
systemctl enable --now snapd.service

waitUntilServiceIsRunning "snapd.socket"
waitUntilServiceIsRunning "snapd.service"
