#!/bin/bash

# Initialize the environment
database_lock="./db.lock"
database="./database.txt"
touch $database_lock  # Ensure the lock file exists
if [ ! -f $database ]; then
    # Populate the database if it does not exist
    echo "ReservationID, CustomerName, Destination" > $database
    echo "101, Catalina Carolina, Satu Mare" >> $database
    echo "102, Antonio Profu, Fundulea" >> $database
    echo "103, Daniel Tanase-Rusu, Moscova" >> $database
fi

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
    write_to_database "104, Alice Eraser, Wild Chicago"
) 200>$database_lock &

for i in {1..5}; do
    (
        flock -s 200
        echo "Reader $i request access"
        read_from_database
    ) 200>$database_lock &
done

wait

