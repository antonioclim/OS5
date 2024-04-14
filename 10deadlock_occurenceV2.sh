#!/bin/bash

# Define the directory where the lock files will be created
lock_dir="$HOME/OS5"

# Ensure the lock directory exists
mkdir -p "$lock_dir"

# Simulating Process P1
(
    if flock -n -w 10 101; then
        echo "Process P1 acquired lock on Resource R1"
        sleep 2
        if flock -n -w 10 102; then
            echo "Process P1 acquired lock on Resource R2"
            flock -u 102
        else
            echo "Process P1 failed to acquire lock on Resource R2"
        fi
        flock -u 101
    else
        echo "Process P1 failed to acquire lock on Resource R1"
    fi
) 101>"$lock_dir/R1.lock" 102>"$lock_dir/R2.lock" &

# Simulating Process P2
(
    if flock -n -w 10 102; then
        echo "Process P2 acquired lock on Resource R2"
        sleep 2
        if flock -n -w 10 101; then
            echo "Process P2 acquired lock on Resource R1"
            flock -u 101
        else
            echo "Process P2 failed to acquire lock on Resource R1"
        fi
        flock -u 102
    else
        echo "Process P2 failed to acquire lock on Resource R2"
    fi
) 101>"$lock_dir/R1.lock" 102>"$lock_dir/R2.lock" &

