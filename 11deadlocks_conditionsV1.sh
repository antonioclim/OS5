#!/bin/bash

# Define the output file for the deadlock detection report
output_file="11deadlocks_conditionsV1.txt"

# Start the report output
{
    echo "Checking for potential deadlocks in system processes..."
    
    # Display processes and their current resource locks
    echo "List of processes with their locked resources:"
    lsof 2>&1 | grep -v "WARNING: can't stat()" | grep "REG" | awk '{print $1, $2, $9}' | sort | uniq -c | sort -nr
    
    # Append a final message about reviewing the system resource usage
    echo "Review the list for potential circular resource usage among processes."
} | tee "$output_file"

# Notify user where the report is saved
echo "Deadlock detection report saved to $output_file"

