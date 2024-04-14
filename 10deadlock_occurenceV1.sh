#!/bin/bash

# Define the directory where the lock files will be created
lock_dir="$HOME/OS5"

# Ensure the lock directory exists
mkdir -p "$lock_dir"

# Simulating Process P1
(
    flock -n 101
    echo "Process P1 acquired lock on Resource R1"
    sleep 2
    flock -n 102
    echo "Process P1 acquired lock on Resource R2"
    flock -u 102
    flock -u 101
) 101>"$lock_dir/R1.lock" 102>"$lock_dir/R2.lock" &

# Simulating Process P2
(
    flock -n 102
    echo "Process P2 acquired lock on Resource R2"
    sleep 2
    flock -n 101
    echo "Process P2 acquired lock on Resource R1"
    flock -u 101
    flock -u 102
) 101>"$lock_dir/R1.lock" 102>"$lock_dir/R2.lock" &

