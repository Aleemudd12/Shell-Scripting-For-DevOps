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

# Ensure file2.txt exists
touch $LOGFILE

# Read existing domains into an array
if [ -f "$LOGFILE" ]; then
  readarray -t existing_domains < "$LOGFILE"
else
  existing_domains=()
fi

# Function to check if a domain is in the array
domain_exists() {
  local domain="$1"
  for d in "${existing_domains[@]}"; do
    if [ "$d" == "$domain" ]; then
      return 0
    fi
  done
  return 1
}

# Process the domains in file1.txt
while IFS= read -r domain; do
  # Remove 'www.' prefix if present
  cleaned_domain=$(echo "$domain" | sed 's/^www\.//')

  # Check if the cleaned domain already exists in file2.txt
  if ! domain_exists "$cleaned_domain"; then
    echo "New domain found: $cleaned_domain"
    echo "$cleaned_domain" >> "$LOGFILE"
    existing_domains+=("$cleaned_domain")
  fi
done < "$FILE1"

echo "Processing complete."
