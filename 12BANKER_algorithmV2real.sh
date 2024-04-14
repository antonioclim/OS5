#!/bin/bash

# Define available resources
declare -A available=( ["A"]=10 ["B"]=5 )

# Define maximum demand for each process
declare -A max_demand=(
    ["P1,A"]=7 ["P1,B"]=5
    ["P2,A"]=3 ["P2,B"]=2
    ["P3,A"]=9 ["P3,B"]=2
)

# Current allocation for each process
declare -A allocation=(
    ["P1,A"]=0 ["P1,B"]=0
    ["P2,A"]=0 ["P2,B"]=0
    ["P3,A"]=0 ["P3,B"]=0
)

# Initialize need based on max_demand and current allocation
declare -A need
for key in "${!max_demand[@]}"; do
    IFS=',' read proc res <<< "${key//,/ }"
    need[$key]=$(( max_demand[$key] - allocation[$key] ))
done

# Function to display current state
display_state() {
    echo "Available Resources: A=${available[A]}, B=${available[B]}"
    echo "Current Allocation and Needs:"
    for p in P1 P2 P3; do
        echo "Process $p: Alloc[A]=${allocation[$p,A]}, Alloc[B]=${allocation[$p,B]}"
        echo "           Need [A]=${need[$p,A]}, Need[B]=${need[$p,B]}"
    done
}

# Function to check if the system is in a safe state
is_safe() {
    local workA=${available[A]}
    local workB=${available[B]}
    local finish=( [P1]=false [P2]=false [P3]=false )
    local safe=true

    for (( i=0; i<3; i++ )); do
        for p in "${!finish[@]}"; do
            if [[ ${finish[$p]} == false && ${need[$p,A]} -le $workA && ${need[$p,B]} -le $workB ]]; then
                workA=$(( workA + allocation[$p,A] ))
                workB=$(( workB + allocation[$p,B] ))
                finish[$p]=true
                echo "Process $p can finish with Work[A]=$workA, Work[B]=$workB"
            fi
        done
    done

    for p in "${!finish[@]}"; do
        if [[ ${finish[$p]} == false ]]; then
            echo "System is not in a safe state."
            safe=false
            break
        fi
    done

    if [[ "$safe" == true ]]; then
        echo "System is in a safe state."
        return 0
    else
        return 1
    fi
}

# Function to request resources
request_resources() {
    local proc=$1
    local reqA=$2
    local reqB=$3

    echo "Process $proc requests A=$reqA, B=$reqB"

    # Check if request exceeds maximum demand
    if (( reqA > max_demand["$proc,A"] || reqB > max_demand["$proc,B"] )); then
        echo "Error: Request exceeds maximum demand for Process $proc"
        return
    fi

    # Temporarily allocate resources
    available[A]=$(( available[A] - reqA ))
    available[B]=$(( available[B] - reqB ))
    allocation["$proc,A"]=$(( allocation["$proc,A"] + reqA ))
    allocation["$proc,B"]=$(( allocation["$proc,B"] + reqB ))
    need["$proc,A"]=$(( need["$proc,A"] - reqA ))
    need["$proc,B"]=$(( need["$proc,B"] - reqB ))

    # Check for safety
    if is_safe; then
        echo "Request approved."
    else
        echo "Request denied. System would be in an unsafe state."
        # Rollback
        available[A]=$(( available[A] + reqA ))
        available[B]=$(( available[B] + reqB ))
        allocation["$proc,A"]=$(( allocation["$proc,A"] - reqA ))
        allocation["$proc,B"]=$(( allocation["$proc,B"] - reqB ))
        need["$proc,A"]=$(( need["$proc,A"] + reqA ))
        need["$proc,B"]=$(( need["$proc,B"] + reqB ))
    fi
}

# Display initial state
display_state

# Example resource requests
request_resources P1 1 2
request_resources P2 2 1

# Display state after requests
display_state

