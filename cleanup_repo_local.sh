#!/bin/bash

# Configuration
MAIN_BRANCH="main"
DATE=$(date +"%Y%m%d")
BACKUP_BRANCH="backup-$DATE"

# Ensure we are in a valid Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: This script must be run from the root of a Git repository."
    exit 1
fi

# Function: Create a backup branch
create_backup_branch() {
    echo "Creating backup branch: $BACKUP_BRANCH"
    
    # Ensure we are on the main branch
    git checkout $MAIN_BRANCH || { echo "Error: Could not switch to main branch."; exit 1; }
    
    # Create the backup branch and push it
    git branch $BACKUP_BRANCH || { echo "Error: Could not create backup branch."; exit 1; }
    git push origin $BACKUP_BRANCH || { echo "Error: Could not push backup branch."; exit 1; }
    
    echo "Backup branch '$BACKUP_BRANCH' created and pushed."
}

# Function: Clear the main branch
clear_main_branch() {
    echo "Clearing the main branch..."
    
    # Ensure we are on the main branch
    git checkout $MAIN_BRANCH || { echo "Error: Could not switch to main branch."; exit 1; }
    
    # Remove all files
    git rm -rf . || { echo "Error: Could not remove files."; exit 1; }
    
    # Add a fresh README.md
    echo "# Central Sequence Service" > README.md
    echo "This repository is a fresh start for implementing the Central Sequence Service based on Vapor and OpenAPIKit." >> README.md
    
    # Commit and push the changes
    git add README.md || { echo "Error: Could not stage README.md."; exit 1; }
    git commit -m "Clean slate for Vapor new setup" || { echo "Error: Could not commit changes."; exit 1; }
    git push --force || { echo "Error: Could not push changes to main branch."; exit 1; }
    
    echo "Main branch cleared and initialized with a fresh README.md."
}

# Main Execution
main() {
    echo "Starting cleanup process for repository..."
    create_backup_branch
    clear_main_branch
    echo "Repository cleanup and reinitialization completed successfully!"
}

# Run the main function
main

