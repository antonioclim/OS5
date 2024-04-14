#!/bin/bash

# Define resources as associative arrays
declare -A total_resources=( ["A"]=10 ["B"]=10 )
declare -A available_resources=( ["A"]=3 ["B"]=2 )

# Maximum demand and allocation as associative arrays with compound keys
declare -A max_demand
max_demand["1,A"]=7
max_demand["1,B"]=5
max_demand["2,A"]=3
max_demand["2,B"]=2
max_demand["3,A"]=9
max_demand["3,B"]=0

declare -A allocation
allocation["1,A"]=0
allocation["1,B"]=1
allocation["2,A"]=2
allocation["2,B"]=1
allocation["3,A"]=3
allocation["3,B"]=0

# Function to check for safe state for a given process
is_safe_state() {
    local process=$1
    local needA=$(( max_demand["$process,A"] - allocation["$process,A"] ))
    local needB=$(( max_demand["$process,B"] - allocation["$process,B"] ))
    
    # Check if needs can be satisfied with available resources
    if (( needA <= available_resources["A"] && needB <= available_resources["B"] )); then
        return 0
    else
        return 1
    fi
}

# Function to simulate resource request
request_resources() {
    local process=$1
    local reqA=$2
    local reqB=$3
    local procA="$process,A"
    local procB="$process,B"

    echo "Process $process requests $reqA units of Resource A and $reqB units of Resource B"

    # Check if request exceeds maximum demand
    if (( reqA > max_demand[$procA] || reqB > max_demand[$procB] )); then
        echo "Error: Request exceeds maximum demand for Process $process"
        return
    fi

    # Temporarily allocate resources
    available_resources["A"]=$(( available_resources["A"] - reqA ))
    available_resources["B"]=$(( available_resources["B"] - reqB ))
    allocation[$procA]=$(( allocation[$procA] + reqA ))
    allocation[$procB]=$(( allocation[$procB] + reqB ))

    # Check for safe state
    if is_safe_state $process; then
        echo "Request granted for Process $process. System is in a safe state."
    else
        echo "Request denied for Process $process. System would be in an unsafe state."
        # Rollback
        available_resources["A"]=$(( available_resources["A"] + reqA ))
        available_resources["B"]=$(( available_resources["B"] + reqB ))
        allocation[$procA]=$(( allocation[$procA] - reqA ))
        allocation[$procB]=$(( allocation[$procB] - reqB ))
    fi
}

# Simulate requests for Process 1 and Process 2
request_resources 1 2 1
request_resources 2 1 1

