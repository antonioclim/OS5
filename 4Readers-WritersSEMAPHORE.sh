#!/bin/bash

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

