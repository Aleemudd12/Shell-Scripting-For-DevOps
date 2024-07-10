#!/bin/bash

# URL to request
URL="http://platf-publi-18fsqbv7zkatz-264338888.us-east-1.elb.amazonaws.com/client/getclienturls"

# Output file
OUTPUT_FILE="getclienturls"

# Make the request and process the response
curl -s $URL | jq -r '.[]' > $OUTPUT_FILE

echo "Response saved to $OUTPUT_FILE in the desired format."

# Define the files
FILE1="getclienturls"
LOGFILE="newdomains.txt"

# Ensure LOGFILE exists
touch "$LOGFILE"

# Create a new file with current date and timestamp for new domains
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
NEW_DOMAINS_FILE="new_domains_${TIMESTAMP}.txt"

# Function to check if a domain is in the file
domain_exists() {
    grep -Fxq "$1" "$LOGFILE"
}

# Variable to track if any new domains were found
new_domains_found=false

# Process the domains in FILE1
while IFS= read -r domain; do
    # Remove 'www.' prefix if present
    cleaned_domain=$(echo "$domain" | sed 's/^www\.//')

    # Check if the cleaned domain already exists in LOGFILE
    if ! domain_exists "$cleaned_domain"; then
        echo "New domain found: $cleaned_domain"
        echo "$cleaned_domain" >> "$LOGFILE"
        echo "$cleaned_domain" >> "$NEW_DOMAINS_FILE"
        new_domains_found=true
    fi
done < "$FILE1"

if [ "$new_domains_found" = true ]; then
    echo "New domains have been added to $NEW_DOMAINS_FILE"
else
    echo "No new domains found."
    rm "$NEW_DOMAINS_FILE"  # Remove the empty file if no new domains were found
fi

echo "Processing complete."
