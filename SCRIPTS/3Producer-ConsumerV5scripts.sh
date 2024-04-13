#!/bin/bash

# Determine the current user's home directory dynamically
get_home_directory() {
    echo $(getent passwd $(whoami) | cut -d: -f6)
}

# Set up the environment and task queue directory
setup_environment() {
    local user_home=$(get_home_directory)
    local task_dir="${user_home}/TaskQueue"
    mkdir -p "${task_dir}"  # Create the task directory if it doesn't exist
    echo "${task_dir}"  # Return the full path to the task directory
}

# Generate tasks
produce_tasks() {
    local queue=$1
    local scripts=("backup_system.sh" "update_system.sh" "clean_logs.sh" "monitor_performance.sh"
                   "check_disk_space.sh" "renew_certificates.sh" "sync_time.sh"
                   "test_network.sh" "archive_old_data.sh" "notify_admin.sh")
    local id=0

    while true; do
        local count=$(ls $queue | wc -l)
        if [[ $count -lt 3 ]]; then  # Limit to 3 tasks in the queue
            local task_script=${scripts[$id % ${#scripts[@]}]}
            local task_file="task_$(date +%Y%m%d%H%M%S)_${task_script}"
            echo "$task_script" > "$queue/$task_file"
            echo "Scheduled task $task_file"
            id=$((id + 1))
            sleep 5  # Schedule a new task every 5 seconds if below capacity
        else
            echo "Queue is full, waiting..."
            sleep 1  # Check more frequently when the queue is full
        fi
    done
}

# Process tasks
consume_tasks() {
    local queue=$1

    while true; do
        local tasks=( $(ls $queue) )
        if [[ ${#tasks[@]} -gt 0 ]]; then
            local task=${tasks[0]}
            local script_to_run=$(cat "$queue/$task")
            echo "Executing $script_to_run..."
            ./"$script_to_run"
            rm -f "$queue/$task"
            echo "Completed $task"
            sleep 2  # Short wait before processing the next task
        else
            echo "Queue is empty, waiting for tasks..."
            sleep 1
        fi
    done
}

# Cleanup function to clear the queue
cleanup() {
    echo "Cleaning up task queue..."
    rm -rf "${queue_path}/*"
    echo "Task queue cleared."
}

# Main script logic
trap cleanup EXIT
queue_path=$(setup_environment)
produce_tasks $queue_path &
consume_tasks $queue_path &
wait

exit 0

