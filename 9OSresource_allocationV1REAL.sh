#!/bin/bash

# Function to monitor system resources
monitor_resources() {
    echo "===== System Resource Report ====="
    echo "$(date)"
    echo "----------------------------------"
    
    # CPU load
    echo "CPU Load Average:"
    cat /proc/loadavg

    # Memory usage
    echo "Memory Usage:"
    free -h

    # Disk usage
    echo "Disk Usage:"
    df -hT | grep -v tmpfs | grep -v udev

    echo "----------------------------------"
}

# Function to identify and kill zombie processes
cleanup_zombies() {
    echo "Checking for zombie processes..."
    zombies=$(ps axo stat,ppid,pid,comm | grep -w defunct)

    if [[ ! -z "$zombies" ]]; then
        echo "Zombie processes found:"
        echo "$zombies"
        while IFS= read -r line; do
            zombie_pid=$(echo $line | awk '{print $3}')
            zombie_ppid=$(echo $line | awk '{print $2}')
            echo "Attempting to kill zombie process PID: $zombie_pid, PPID: $zombie_ppid"
            # Sending SIGCHLD to the parent process
            kill -s SIGCHLD $zombie_ppid
            # If it doesn't clean up the zombie, then kill the zombie forcefully
            kill -9 $zombie_pid
        done <<< "$zombies"
        echo "Zombie processes handled."
    else
        echo "No zombie processes found."
    fi
    echo "----------------------------------"
}

# Main function to run the scripts
main() {
    monitor_resources
    cleanup_zombies
}

# Execute the main function
main

