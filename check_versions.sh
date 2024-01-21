#!/bin/bash

# Function to check and display version
check_version() {
    program=$1
    version_command=$2

    echo -n "$program version: "
    $version_command 2>/dev/null || echo "Not installed"
}

# Check Go version
check_version "Go" "go version"

# Check Rust version
check_version "Rust" "rustc --version"

# Check Python version
check_version "Python" "python3 --version"
