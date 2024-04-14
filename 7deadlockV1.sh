#!/bin/bash

# Simulating resource allocation
exec 200>/tmp/lockfile1
exec 201>/tmp/lockfile2

# Process 1 acquires lockfile1 and waits for lockfile2
flock -n 200 || exit 1
echo "Process 1 acquired resource 1"
sleep 1
flock -n 201 || exit 1
echo "Process 1 acquired resource 2"

# Process 2 acquires lockfile2 and waits for lockfile1
flock -n 201 || exit 1
echo "Process 2 acquired resource 2"
sleep 1
flock -n 200 || exit 1
echo "Process 2 acquired resource 1"

# Release locks
flock -u 200
flock -u 201

