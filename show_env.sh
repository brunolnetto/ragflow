#!/bin/bash

# Function to obtain distribution information
get_distro_info() {
    local distro_id=$(lsb_release -i -s 2>/dev/null)
    local distro_version=$(lsb_release -r -s 2>/dev/null)
    local kernel_version=$(uname -r)

    if [ -z "$distro_id" ] || [ -z "$distro_version" ]; then
        if [ -f /etc/os-release ]; then
            distro_id=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
            distro_version=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
        else
            distro_id="Unknown"
            distro_version="Unknown"
        fi
    fi

    echo "$distro_id $distro_version (Kernel version: $kernel_version)"
}

# Get Git repository name
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    git_repo_name=$(basename "$(git rev-parse --show-toplevel)")
else
    git_repo_name="Not a Git repository"
fi

# Get Git commit ID
if command -v git &> /dev/null && git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    git_version=$(git log -1 --pretty=format:'%h')
else
    git_version="Unavailable"
fi

# Get CPU type
cpu_model=$(uname -m)

# Get memory size
memory_size=$(free -h | awk '/^Mem:/ {print $2}')

# Get Docker version
if command -v docker &> /dev/null; then
    docker_version=$(docker --version 2>/dev/null | head -n 1 | awk '{print $3}' | sed 's/,//')
    [ -z "$docker_version" ] && docker_version="Installed but version not detected"
else
    docker_version="Not installed"
fi

# Get Python versions
python2_version=""
python3_version=""
if command -v python &> /dev/null; then
    python2_version=$(python --version 2>&1 | awk '{print $2}')
fi
if command -v python3 &> /dev/null; then
    python3_version=$(python3 --version 2>&1 | awk '{print $2}')
fi

# Prepare Python version summary
if [ -n "$python2_version" ] && [ -n "$python3_version" ]; then
    python_version="$python2_version | Python 3: $python3_version"
elif [ -n "$python3_version" ]; then
    python_version="$python3_version"
elif [ -n "$python2_version" ]; then
    python_version="$python2_version"
else
    python_version="Python not installed"
fi

# Print system information
echo "Repository Name : $git_repo_name"
echo "Latest Commit   : $git_version"
echo "OS & Kernel     : $(get_distro_info)"
echo "CPU Architecture: $cpu_model"
echo "Memory Size     : $memory_size"
echo "Docker Version  : $docker_version"
echo "Python Version  : $python_version"
