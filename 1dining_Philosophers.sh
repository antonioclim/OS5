#!/bin/bash

acquire_fork() {
    exec {lock_fd}>"/tmp/fork$1.lock"
    flock -x "$lock_fd"
    echo "Philosopher $2 has acquired fork $1"
}

release_fork() {
    flock -u "$lock_fd"
    exec {lock_fd}>&-
    echo "Philosopher $1 has released their forks"
}

eat() {
    echo "Philosopher $1 is eating"
    sleep 2
}

philosopher() {
    local id=$1
    local left_fork=$((id % 5 + 1))
    local right_fork=$(((id + 1) % 5 + 1))
    
    acquire_fork $left_fork $id
    acquire_fork $right_fork $id
    eat $id
    release_fork $id
}

for i in {1..5}; do
    philosopher $i &
    sleep 2
done

wait
echo "All philosophers have finished."

