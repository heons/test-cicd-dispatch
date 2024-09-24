#!/bin/bash

# export LC_ALL=C

# Function to validate month input
validate_month() {
    local month=$1
    if [[ $month =~ ^[0-9]+$ ]] && (( month >= 1 && month <= 12 )); then
        printf "%02d\n" "$month"
    else
        echo "Invalid month. Please enter a number between 1 and 12." >&2
        exit 1
    fi
}

# Get the new month from user input
read -p "Enter the new month (1-12): " new_month
new_month=$(validate_month "$new_month")

# File to modify
file="index.txt"

# Backup the original file
cp "$file" "${file}.bak"

# Read the file line by line
while read -r line; do
    # Check if the line matches our pattern
    if [[ $line =~ ^\"aurora-uat\"[[:space:]]*=[[:space:]]*\[[^]]+\]$ ]]; then
        echo $line

        # Extract the year and months
        months=($(echo "$line" | grep -oP '(?<=")[0-9]{4}-[0-9]{2}(?=")' | sort))
        
        # Determine the year for the new month
        year=${months[-1]%-*}
        
        # Create the new month string
        new_month_string="$year-$new_month"
        
        # Shift the array by removing the first element and adding the new one
        new_months=("${months[@]:1}")
        new_months+=("$new_month_string")
        
        # Format the new line
        new_line="\"aurora-uat\" = [\"${new_months[0]}\",\"${new_months[1]}\"]"
        echo $new_line

        escaped_line=$(printf '%s\n' "$line" | sed -e 's/["[\&]/\\&/g')
        echo $escaped_line
        # Escape special characters in the replacement string
        escaped_new_line=$(printf '%s\n' "$new_line" | sed -e 's/["[\/&]/\\&/g')
        echo $escaped_new_line
        
        # Replace the old line with the new one
        sed -i "s/$escaped_line/$escaped_new_line/" "$file"
    fi
done < "${file}.bak"

# Remove the backup file
rm "${file}.bak"
