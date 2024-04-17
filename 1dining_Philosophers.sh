#!/bin/bash

#This script simulates the classic Dining Philosophers problem using file locking in Bash. 
#  We'll explore concepts like file locking (flock), background processes, and simulating 
#  philosopher actions (thinking, acquiring forks, eating, releasing forks).

#Explanation:
#	•	The script utilizes file locking (flock) to simulate the philosophers' actions of acquiring and releasing forks. 
#                 Each fork is represented by a unique lock file.
#	•	The philosopher function ensures a specific order for acquiring forks (left fork first, then right) to avoid 
#                 deadlocks where multiple philosophers wait for each other's forks indefinitely.
#	•	The script simulates thinking and eating durations with delays (sleep) for demonstration purposes. In a real scenario, 
#                 these would be replaced with the philosophers' actual thinking and eating activities.
#	•	By using background processes for each philosopher, we create a concurrent environment where philosophers can think, 
#                 acquire forks, eat, and release forks independently.


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

