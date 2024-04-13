#!/bin/bash

# Function to determine the current user's home directory dynamically
get_home_directory() {
    echo $(getent passwd $(whoami) | cut -d: -f6)
}

# Set up the environment and buffer directory
setup_environment() {
    local user_home=$(get_home_directory)
    local os5_dir="${user_home}/OS5"
    mkdir -p "${os5_dir}/buffer"  # Create the buffer directory if it doesn't exist
    echo "${os5_dir}/buffer"  # Return the full path to the buffer directory
    echo -e "WhatsApp\nTikTok\nGameApp\nMsWord\nFriendlyApp\nEXAMtaken\nOnlineASEro\nEXAMfailed" > "${os5_dir}/products_list.txt"
    for i in {1..100}; do echo "App_as_Product$i" >> "${os5_dir}/products_list.txt"; done
}

# Load products from file
load_products() {
    local products_path=$1
    mapfile -t products < "$products_path"
    echo "${products[@]}"
}

# Produce items into the buffer
produce() {
    local buffer=$1
    local products=("$@")
    local product_count=${#products[@]}
    local id=1

    while true; do
        local count=$(ls $buffer | wc -l)
        if [[ $count -lt 20 ]]; then  # Increased buffer capacity to 20
            local item="${products[$RANDOM % $product_count]}_$id"
            touch "$buffer/$item"
            echo "Produced $item"
            id=$((id % 25 + 1))
            sleep 0.5  # Reduced sleep for faster production
        else
            echo "Buffer is full, waiting..."
            sleep 0.5  # Reduced wait time when buffer is full
        fi
    done
}

# Consume items from the buffer
consume() {
    local buffer=$1
    while true; do
        local items=( $(ls $buffer) )
        if [[ ${#items[@]} -gt 0 ]]; then
            local item=${items[0]}
            rm -f "$buffer/$item"
            echo "Consumed $item"
            sleep 1  # Reduced sleep for faster consumption
        else
            echo "Buffer is empty, waiting..."
            sleep 1
        fi
    done
}

# Cleanup function to clear the buffer and remove all files
cleanup() {
    echo "Cleaning up buffer..."
    rm -rf "${buffer_path}/*"
    echo "All items cleared from buffer."
}

# Main script logic
trap cleanup EXIT  # Ensure cleanup runs on script exit
buffer_path=$(setup_environment)
products_path="${buffer_path%/*}/products_list.txt"
products=( $(load_products $products_path) )
produce $buffer_path "${products[@]}" &
consume $buffer_path &
wait

