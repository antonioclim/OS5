#!/bin/bash

# Determine the current user's home directory dynamically
user_home=$(eval echo ~$(whoami))

# Define the directory where the log files will be created
log_dir="$user_home/OS5/logs"

# Ensure the log directory exists
mkdir -p "$log_dir"

# Define the temporary log file for current usage stats
log_file="$log_dir/sys_usage_$(date +%Y%m%d_%H%M%S).log"

# Function to collect system metrics
collect_metrics() {
    echo "Collecting system metrics..."
    echo "Timestamp: $(date)" > "$log_file"
    echo "CPU Usage:" >> "$log_file"
    mpstat 1 1 >> "$log_file"
    echo "Memory Usage:" >> "$log_file"
    free -h >> "$log_file"
    echo "Disk Usage:" >> "$log_file"
    df -h >> "$log_file"
}

# Function to clean up old logs (retain last 5 logs)
cleanup_old_logs() {
    echo "Cleaning up old logs..."
    ls -tp $log_dir | grep -v '/$' | tail -n +6 | xargs -I {} rm -- "$log_dir/{}"
}

# Main script execution
collect_metrics
cleanup_old_logs
echo "System resource metrics collected and old logs cleaned. See current log at $log_file"

