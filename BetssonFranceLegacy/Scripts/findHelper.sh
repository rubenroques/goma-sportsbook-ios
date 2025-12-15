#!/bin/bash

# Change directory to the root of your Xcode project
cd /path/to/your/project

# Find all Swift files and loop through them
find . -name "*.swift" | while read file; do
    # Use grep to find lines containing "Env.serviceProvider"
    if grep -q "Env\.servicesProvider" "$file"; then
        # Print the file name
        echo "File: $file"
        # Print the lines containing "Env.serviceProvider"
        grep "Env\.servicesProvider" "$file"
    fi
done
