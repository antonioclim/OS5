#!/bin/bash

# Determine the current user's home directory dynamically
user_home=$(eval echo ~$(whoami))

# Path to the folder where the lock files are located
lock_folder="$user_home/OS5"

# Ensure the lock folder exists
mkdir -p "$lock_folder"

# Resource files
resource1="$lock_folder/resource1.lock"
resource2="$lock_folder/resource2.lock"

# Populate the lock files with initial content
echo "Resource ID: 1" > "$resource1"
echo "Last Locked: $(date)" >> "$resource1"
echo "Lock Status: Unlocked" >> "$resource1"

echo "Resource ID: 2" > "$resource2"
echo "Last Locked: $(date)" >> "$resource2"
echo "Lock Status: Unlocked" >> "$resource2"

echo "Lock files have been created and populated with initial content."

