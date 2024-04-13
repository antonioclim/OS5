#!/bin/bash

# Cleanup function to ensure all locks are released and temporary files removed
cleanup() {
    rm -f /tmp/fork{1..5}.lock
    echo "Cleaned up resources."
}

# Function to simulate acquiring a fork
acquire_fork() {
    fork_number=$1
    lockfile="/tmp/fork${fork_number}.lock"

    # Attempt to acquire the lock
    exec {fd}>$lockfile
    if flock -n $fd; then
        echo "Philosopher $2 acquired fork $fork_number"
        return 0
    else
        echo "Philosopher $2 could not acquire fork $fork_number"
        return 1
    fi
}

# Function to simulate a philosopher
philosopher() {
    id=$1
    left_fork=$id
    right_fork=$((id % 5 + 1))

    while true; do
        if acquire_fork $left_fork $id; then
            if acquire_fork $right_fork $id; then
                echo "Philosopher $id starts eating."
                sleep $((RANDOM % 3 + 2))
                echo "Philosopher $id finishes eating and puts down forks."
                flock -u $fd
                exec {fd}>&-
                break
            else
                # Release the left fork if the right fork is not available
                flock -u $fd
                exec {fd}>&-
                echo "Philosopher $id puts down fork $left_fork and continues thinking."
            fi
        fi
        sleep $((RANDOM % 3 + 1))
    done
}

trap cleanup EXIT

# Create temporary lock files
touch /tmp/fork{1..5}.lock

# Start each philosopher in the background
for i in {1..5}; do
    philosopher $i &
    sleep 1
done

wait
echo "All philosophers have finished."

