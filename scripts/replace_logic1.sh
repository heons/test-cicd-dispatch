#!/bin/bash


# # Read the input value from the user
# read -p "Enter the new date (YYYY-MM): " new_date

if [ $# -eq 0 ]; then
    echo "Usage: $0 <new_date>"
    echo "Example: $0 2024-10"
    exit 1
fi

# Get the new date from the command-line argument
new_date="$1"

# Validate the date format
if [[ ! "$new_date" =~ ^[0-9]{4}-[0-9]{2}$ ]]; then
    echo "Invalid date format. Please use YYYY-MM."
    exit 1
fi

# File to modify
file="index.txt"

# Backup the original file
cp "$file" "${file}.bak"

# Read the file line by line
while read -r line; do
    # Check if the line matches our pattern
    if [[ $line =~ ^\"aurora-uat\"[[:space:]]*=[[:space:]]*\[[^]]+\]$ ]]; then
        echo $line

        # Extract the array content
        array_content=${line#*\[}
        array_content=${array_content%\]*}
        
        # Split the array content into individual dates
        IFS=',' read -ra dates <<< "$array_content"
        
        # Remove the first element (oldest date) and add the new date
        modified_dates="${dates[@]:1}"
        modified_dates="$modified_dates,\"$new_date\""
        
        # Reconstruct the line with the modified array
        modified_line="\"aurora-uat\" = [$modified_dates]"
        
        # Print the modified line
        echo $modified_line
        # echo "$modified_line" >> "$temp_file"

        # Escape special characters in the replacement string
        escaped_line=$(printf '%s\n' "$line" | sed -e 's/["[\&]/\\&/g')
        echo $escaped_line
        escaped_new_line=$(printf '%s\n' "$modified_line" | sed -e 's/["[\/&]/\\&/g')
        echo $escaped_new_line
        
        # Replace the old line with the new one
        sed -i "s/$escaped_line/$escaped_new_line/" "$file"
    fi
done < "${file}.bak"

# Remove the backup file
rm "${file}.bak"
