#!/bin/bash

# Set up the directory and configuration files
setup_environment() {
    local user_home=$(getent passwd $(whoami) | cut -d: -f6)
    local os5_dir="${user_home}/OS5"
    mkdir -p "${os5_dir}"  # Create the directory if it doesn't exist

    # Define paths to configuration files
    CONFIG_FILE1="${os5_dir}/config1.cfg"
    CONFIG_FILE2="${os5_dir}/config2.cfg"

    # Create configuration files if they do not exist
    touch "${CONFIG_FILE1}"
    touch "${CONFIG_FILE2}"
}

# Function to acquire a lock on a file
acquire_lock() {
    local file_path=$1
    local service_id=$2
    local exec_fd=$3

    # Try to acquire the lock
    eval "exec $exec_fd>$file_path"
    if ! flock -n $exec_fd; then
        echo "Service $service_id: Failed to acquire lock on $file_path"
        return 1
    else
        echo "Service $service_id: Acquired lock on $file_path"
        return 0
    fi
}

# Service function simulating the work needing two resources
service_process() {
    local service_id=$1
    local fd1=$((service_id + 3)) # Dynamic file descriptor for the first file
    local fd2=$((service_id + 103)) # Dynamic file descriptor for the second file

    # Attempt to acquire locks on both configuration files
    if acquire_lock "$CONFIG_FILE1" $service_id $fd1; then
        if acquire_lock "$CONFIG_FILE2" $service_id $fd2; then
            echo "Service $service_id: Both locks acquired, processing..."
            sleep $((RANDOM % 3 + 1)) # Simulate some processing time
            echo "Service $service_id: Processing complete, releasing locks."
            # Release locks
            flock -u $fd1
            flock -u $fd2
            eval "exec $fd1>&-"
            eval "exec $fd2>&-"
        else
            # Release the first lock if the second couldn't be acquired
            flock -u $fd1
            eval "exec $fd1>&-"
            echo "Service $service_id: Released fork $fd1 after failing to acquire fork $fd2"
        fi
    fi
}

# Main script execution
setup_environment

# Start multiple services in the background
for i in {1..5}; do
    service_process $i &
    sleep 1
done

wait
echo "All services have finished."
