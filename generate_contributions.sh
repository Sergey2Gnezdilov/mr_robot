#!/bin/bash

# Source the font definitions
source "$(dirname "$0")/font.sh"

# Function to make commits for a specific date
make_commit() {
    local date="$1"
    local count="$2"
    echo "Making $count commits for $date"
    for ((i=0; i<count; i++)); do
        echo "$date-$i" > temp.txt
        git add temp.txt
        GIT_AUTHOR_DATE="$date 12:00:00 +0200" GIT_COMMITTER_DATE="$date 12:00:00 +0200" git commit -m "commit for $date"
    done
}

# Generate commits array for MR.ROBOT
start_date="2017-01-01"  # Sunday
echo "Generating commit matrix..."
matrix_output=$(matrix_to_commits "MR.ROBOT" "$start_date")
echo "Matrix output:"
echo "$matrix_output"

# Create initial empty commit
echo "Creating initial commit..."
git add temp.txt
git commit -m "Initial commit"

# Make commits according to pattern
echo "Creating pattern commits..."
echo "Extracting dates and intensities..."

# Extract dates and intensities from the matrix output
eval "$matrix_output"

# Create an associative array to track processed dates
declare -A processed_dates

for ((i=0; i<${#commits[@]}; i+=2)); do
    date="${commits[i]}"
    intensity="${commits[i+1]}"
    
    # Skip if we've already processed this date
    if [[ -z "${processed_dates[$date]}" ]]; then
        echo "Processing: date=$date intensity=$intensity"
        make_commit "$date" "$intensity"
        processed_dates[$date]=1
    fi
done

echo "Done! Total commits created: $(git rev-list --count HEAD)"

echo "Done! Total commits created: $(git rev-list --count HEAD)"
