#!/bin/bash

# Define the directory where the lock files will be stored
lock_dir="$HOME/OS5"

# Ensure the directory exists
mkdir -p "$lock_dir"

# Function to attempt to acquire a lock with a timeout
acquire_lock() {
    local file="$lock_dir/$1"
    exec {fd}>$file  # Open the file and assign a dynamic file descriptor
    if flock -w 5 "$fd"; then
        echo "$fd"  # Return the file descriptor if the lock is successful
    else
        echo "fail"  # Indicate failure
        exec {fd}>&-  # Close the file descriptor on failure to lock
    fi
}

# Function to release a lock and close the descriptor
release_lock() {
    local fd=$1
    if [[ "$fd" =~ ^[0-9]+$ ]]; then  # Ensure fd is a number, indicating a valid descriptor
        if { true >&"$fd"; } 2>/dev/null; then  # Check if fd is still open
            flock -u "$fd"  # Unlock the file
            exec {fd}>&-  # Close the file descriptor
        fi
    fi
}

# Function to simulate a process operation
simulate_process() {
    local process_id=$1
    local first_lock=$2
    local second_lock=$3

    echo "Process $process_id starting."
    local first_fd=$(acquire_lock $first_lock)
    if [ "$first_fd" != "fail" ]; then
        echo "Process $process_id acquired lock on $first_lock."

        sleep 2  # Simulate some work

        local second_fd=$(acquire_lock $second_lock)
        if [ "$second_fd" != "fail" ]; then
            echo "Process $process_id acquired lock on $second_lock."
            sleep 2
            echo "Process $process_id completed work."

            release_lock "$second_fd"
        else
            echo "Process $process_id failed to acquire lock on $second_lock."
        fi

        release_lock "$first_fd"
    else
        echo "Process $process_id failed to acquire lock on $first_lock."
    fi
}

# Start both processes in the background to simulate concurrent access
simulate_process 1 R1.lock R2.lock &
simulate_process 2 R2.lock R1.lock &
wait # Ensure the script waits for both processes to complete

