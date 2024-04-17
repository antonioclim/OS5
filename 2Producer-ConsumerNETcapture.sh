#!/bin/bash

# This script simulates a network packet capture and analysis scenario. It demonstrates concepts like process management, background execution, 
#   file manipulation, and basic string searching. We'll explore how the script simulates capturing packets, analyzing them for suspicious content
#   and managing the capture and analysis processes.


# Explanation:
#      •	The script utilizes two background processes:
#           o	capture_packets: Simulates capturing packets and writing them to the queue directory.
#           o	analyze_packets: Continuously checks the queue directory for new packets, analyzes them for suspicious content, and moves them to the analysis directory.
#      •	Both processes check the runtime limit periodically and exit if reached.
#      •	The grep command with a pattern like "DATA=.*baddata" simulates searching for specific content in the packet data. You can customize this pattern to match 
#                 your desired criteria for suspicious content.
#      •	The sleep commands in both functions introduce delays to simulate realistic time intervals between packet captures and analysis.




# Configuration
network_interface="eth0"
user_home=$(getent passwd $(whoami) | cut -d: -f6)
base_dir="${user_home}/OS5"
queue_dir="${base_dir}/packet_queue"
analysis_dir="${base_dir}/packet_analysis"
runtime_limit=20  # Runtime limit in seconds (1/3 minutes)

# Setup environment
mkdir -p "$queue_dir" "$analysis_dir"

# Start time
start_time=$(date +%s)

# Function to simulate packet capture and queuing
capture_packets() {
    while true; do
        # Check for runtime limit
        local current_time=$(date +%s)
        local elapsed=$(( current_time - start_time ))
        if [ "$elapsed" -ge "$runtime_limit" ]; then
            echo "Runtime limit reached, stopping packet capture..."
            break
        fi

        # Simulate a packet with random data
        local packet="packet_$(date +%s%N).dat"
        echo "SRC=$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1) DST=$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1) DATA=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 100)" > "$queue_dir/$packet"
        echo "Captured and queued packet $packet"
        sleep 0.1  # Simulate interval between packet captures
    done
}

# Function to process packets from the queue
analyze_packets() {
    while true; do
        # Check for runtime limit
        local current_time=$(date +%s)
        local elapsed=$(( current_time - start_time ))
        if [ "$elapsed" -ge "$runtime_limit" ]; then
            echo "Runtime limit reached, stopping packet analysis..."
            break
        fi

        for packet in "$queue_dir"/*; do
            if [ -f "$packet" ]; then
                # Simulate packet analysis: search for suspicious patterns
                if grep -q "DATA=.*baddata" "$packet"; then
                    echo "Alert: Suspicious packet detected: $(cat $packet)"
                fi
                # Move to analysis directory after analysis
                mv "$packet" "$analysis_dir/"
                echo "Analyzed and moved $packet"
            fi
        done
        sleep 0.5  # Polling interval for new packets
    done
}

# Cleanup function to clear the queues
cleanup() {
    echo "Cleaning up packet queues..."
    rm -rf "${queue_dir}/*" "${analysis_dir}/*"
    echo "Packet queues cleared."
}

# Main script logic
trap cleanup EXIT
capture_packets &
capture_pid=$!
analyze_packets &
analyze_pid=$!

# Ensure script stops after 2 minutes
( sleep $runtime_limit && kill -TERM $capture_pid $analyze_pid &>/dev/null ) &

wait

