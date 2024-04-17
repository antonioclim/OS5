#!/bin/bash

#This script simulates a barber shop scenario with a limited waiting area using file locking in Bash. 
#  We'll explore concepts like file locking (flock), background processes, simulating customer arrivals 
#  and barber actions, and managing a customer queue.


#Key Points:
#	•	The barber acquires the lock for exclusive access when checking the queue, reading a customer, 
#		  or performing a haircut. This ensures only one customer is served at a time.
#	•	Customers acquire the lock for exclusive access only when checking the queue availability to avoid 
#		  race conditions where multiple customers might try to add themselves simultaneously.
#	•	Releasing the lock after critical sections (checking queue, adding/removing customer) is crucial to 
#		  allow other processes (barber or customers) to acquire it and proceed.


# Define maximum waiting customers and total customers
MAX_WAITING_CUSTOMERS=3
TOTAL_CUSTOMERS=7

# Files for locks and customer queue management
mutex_lock="/tmp/mutex.lock"
customer_queue="/tmp/customer_queue.txt"

# Initialize the barber shop
touch "$mutex_lock"
echo "" > "$customer_queue"

# Function for the barber to process customers
barber() {
    local served=0
    while [ "$served" -lt "$TOTAL_CUSTOMERS" ]; do
        flock -x 200

        # Check if there are customers waiting
        if [ $(wc -l < "$customer_queue") -gt 0 ]; then
            # Simulate reading the first customer in the queue
            local customer_id=$(head -n 1 "$customer_queue")
            echo "Barber starts a haircut for Customer $customer_id."
            sleep 3
            echo "Barber finishes a haircut for Customer $customer_id."
            # Remove the first customer from the queue
            sed -i '1d' "$customer_queue"
            ((served++))
        else
            echo "Barber is sleeping."
            sleep 1
        fi

        flock -u 200
    done
    echo "Barber's day ends after serving all customers."
}

# Function for customers to enter the shop
customer() {
    local id=$1
    sleep $((id))  # Simulate customer arrival time

    flock -x 200
    if [ $(wc -l < "$customer_queue") -lt "$MAX_WAITING_CUSTOMERS" ]; then
        echo "$id" >> "$customer_queue"
        echo "Customer $id arrives and sits in the waiting room."
    else
        echo "Customer $id leaves because no chairs are available."
        flock -u 200
        sleep 5  # Wait for 5 seconds before possibly retrying
        customer $id  # Retry entering the shop
        return
    fi
    flock -u 200
}

# Start the barber in a background process
exec 200>"$mutex_lock"
barber &

# Create customers
for (( i=1; i<=TOTAL_CUSTOMERS; i++ )); do
    customer $i &
done

wait

