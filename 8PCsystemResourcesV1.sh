#!/bin/bash

# Determine the current user's home directory dynamically
user_home=$(eval echo ~$(whoami))

# Define the directory where the temporary file will be created
temp_dir="$user_home/OS5"

# Ensure the directory exists
mkdir -p "$temp_dir"

# Create a temporary file in the specified directory
temp_file=$(mktemp "$temp_dir/myapp.XXXXXX")

# Use the temporary file to store intermediate data
echo "Storing intermediate data..." > "$temp_file"

# Simulate some processing
sleep 15

# Display the contents of the temporary file
echo "Contents of the temporary file:"
cat "$temp_file"

# Clean up the temporary file
rm "$temp_file"
echo "Temporary file removed."

# End of script

