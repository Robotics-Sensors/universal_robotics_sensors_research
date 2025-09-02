#!/bin/bash
# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Function to check if a remote exists
check_remote() {
    git remote | grep -q "^$1\$"
    return $?
}

# Get list of remotes
remotes=$(git remote)

# Check if origin is the only remote
if [ "$(echo "$remotes" | wc -l)" -eq 1 ] && [ "$remotes" = "origin" ]; then
    echo "Detected single origin remote. Using simple push..."
    
    # Simple push for origin
    git pull --no-edit || handle_error "Failed to pull from origin"
    git fetch || handle_error "Failed to fetch"
    git add .
    git commit -am "latest pushes"
    git push || handle_error "Failed to push to origin"
    
else
    echo "Detected multiple remotes. Using multi-remote push..."
    
    # Check if github or bellande remotes exist (continue regardless)
    has_github=false
    has_gitlab=false
    has_bitbucket=false
    has_bellande=false
    
    if check_remote "github"; then
        has_github=true
        echo "Found GitHub remote"
    fi

    if check_remote "gitlab"; then
        has_gitlab=true
        echo "Found GitLab remote"
    fi

    if check_remote "bitbucket"; then
        has_bitbucket=true
        echo "Found BitBucket remote"
    fi
    
    if check_remote "bellande"; then
        has_bellande=true
        echo "Found Bellande remote"
    fi
    
    # If neither exists, just proceed with available remotes
    if [ "$has_github" = false ] && [ "$has_gitlab" = false ] && [ "$has_bitbucket" = false ] && [ "$has_bellande" = false ]; then
        echo "Neither github, gitlab, bitbucket, bellande remotes found. Continuing with available remotes..."
    fi
    
    # Pull from primary remote (GitHub if available, otherwise skip)
    if [ "$has_github" = true ]; then
        git pull github main --no-edit || handle_error "Failed to pull from GitHub"
    else
        echo "Skipping pull from GitHub (remote not found)"
    fi
    
    # Fetch from all remotes
    git fetch --all || handle_error "Failed to fetch from remotes"
    
    # Add and commit changes
    git add .
    git commit -am "latest pushes"
    
    # Push to GitHub if available
    if [ "$has_github" = true ]; then
        echo "Pushing to GitHub..."
        git push github main || handle_error "Failed to push to GitHub"
    else
        echo "Skipping push to GitHub (remote not found)"
    fi
    
    # Push to Gitlab if available
    if [ "$has_gitlab" = true ]; then
        echo "Pushing to GitLab..."
        git push gitlab main || handle_error "Failed to push to GitLab"
    else
        echo "Skipping push to GitLab (remote not found)"
    fi

    # Push to BitBucket if available
    if [ "$has_bitbucket" = true ]; then
        echo "Pushing to BitBucket..."
        git push bitbucket main || handle_error "Failed to push to BitBucket"
    else
        echo "Skipping push to BitBucket (remote not found)"
    fi

    # Push to Bellande if available
    if [ "$has_bellande" = true ]; then
        echo "Pushing to Bellande Technologies..."
        git push bellande main || handle_error "Failed to push to Bellande"
    else
        echo "Skipping push to Bellande (remote not found)"
    fi
    
    echo "Push operations completed"
fi
