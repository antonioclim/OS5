#!/bin/bash

# Function to check CPU and Memory Usage
check_resources() {
    echo "Checking CPU Load..."
    uptime

    echo "Checking Memory Usage..."
    free -h

    echo "Checking Disk Space..."
    df -h
}

# Run the resource check
check_resources

