#!/bin/bash

#This script demonstrates how to manage concurrent access to a database file using file locking in Bash. 
# We'll explore concepts like file locking mechanisms (flock), background processes, and simulating database operations.

#1	The flock command with different options (-x for exclusive lock and -s for shared lock) ensures only one process 
#                can write to the database at a time while allowing multiple readers to access the data concurrently. 
#                This prevents data corruption due to simultaneous modifications.

#2	The script simulates database operations with delays to demonstrate the locking mechanism. In a real scenario, 
#               the delays would be replaced with actual database access calls or interactions with a database management system.

#3	By using background processes for both writer and reader simulations, we showcase how multiple processes can contend for 
#                access to the database file while maintaining data integrity through proper locking.



database_lock="./db.lock"
database="./database.txt"

write_to_database() {
    flock -x 200
    echo "Writing to database..."
    echo "$1" >> $database
    sleep 2  # Simulate database write operation
    flock -u 200
    echo "Write complete."
}

read_from_database() {
    flock -s 200
    echo "Reading from database..."
    cat $database
    sleep 1  # Simulate database read operation
    flock -u 200
    echo "Read complete."
}

# Simulating access
(
    flock -x 200
    echo "Writer request access"
    write_to_database "New Entry $(date)"
) 200>$database_lock &

for i in {1..5}; do
    (
        flock -s 200
        echo "Reader $i request access"
        read_from_database
    ) 200>$database_lock &
done

wait

