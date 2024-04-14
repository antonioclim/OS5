#!/bin/bash

# Script name and PID for identification
script_name="deadlock_manager"
pid=$$

# Determine the current user's home directory dynamically
user_home=$(eval echo ~$(whoami))

# Path to the folder where the lock files are located
lock_folder="$user_home/OS5"

# Ensure the lock folder exists
mkdir -p "$lock_folder"

# Resource files and lock files
resource1="$lock_folder/resource1.lock"
resource2="$lock_folder/resource2.lock"

# Open file descriptors globally to manage their lifecycle correctly
exec 200>"$resource1"
exec 201>"$resource2"

# Function to acquire a lock on a resource
acquire_lock() {
    local lock_fd=$1
    if ! flock -n $lock_fd; then
        echo "$script_name ($pid): Failed to acquire lock on descriptor $lock_fd"
        return 1
    fi
    echo "$script_name ($pid): Acquired lock on descriptor $lock_fd"
    return 0
}


# Function to release a lock on a resource
release_lock() {
    local lock_fd=$1
    flock -u $lock_fd
    echo "$script_name ($pid): Released lock on descriptor $lock_fd"
}

# Function to simulate work using the resource
perform_work() {
    echo "$script_name ($pid): Working with both resources"
    sleep 10  # Simulate work duration
}

# Attempt to acquire both resources
try_acquire_both_resources() {
    if acquire_lock 200 && acquire_lock 201; then
        perform_work
        release_lock 200
        release_lock 201
    else
        echo "$script_name ($pid): Retrying after 5 seconds due to failed lock acquisition"
        sleep 5
        try_acquire_both_resources
    fi
}

# Start the script by trying to acquire resources
try_acquire_both_resources

