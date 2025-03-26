#!/bin/bash

# Define letters in 7x5 matrix format
declare -A LETTERS

LETTERS[A]=$'00100\n01010\n10001\n11111\n10001\n10001\n00000'

LETTERS[B]=$'11110\n10001\n10001\n11110\n10001\n10001\n11110'

LETTERS[C]=$'01111\n10000\n10000\n10000\n10000\n10000\n01111'

LETTERS[D]=$'11110\n10001\n10001\n10001\n10001\n10001\n11110'

LETTERS[E]=$'11111\n10000\n10000\n11110\n10000\n10000\n11111'

LETTERS[F]=$'11111\n10000\n10000\n11110\n10000\n10000\n10000'

LETTERS[G]=$'01111\n10000\n10000\n10011\n10001\n10001\n01111'

LETTERS[H]=$'10001\n10001\n10001\n11111\n10001\n10001\n10001'

LETTERS[I]=$'11111\n00100\n00100\n00100\n00100\n00100\n11111'

LETTERS[J]=$'11111\n00100\n00100\n00100\n00100\n10100\n01100'

LETTERS[K]=$'10001\n10010\n10100\n11000\n10100\n10010\n10001'

LETTERS[L]=$'10000\n10000\n10000\n10000\n10000\n10000\n11111'

LETTERS[M]=$'10001\n11011\n10101\n10001\n10001\n10001\n10001'

LETTERS[N]=$'10001\n11001\n10101\n10011\n10001\n10001\n10001'

LETTERS[O]=$'01110\n10001\n10001\n10001\n10001\n10001\n01110'

LETTERS[P]=$'11110\n10001\n10001\n11110\n10000\n10000\n10000'

LETTERS[Q]=$'01110\n10001\n10001\n10001\n10101\n10010\n01101'

LETTERS[R]=$'11110\n10001\n10001\n11110\n10100\n10010\n10001'

LETTERS[S]=$'01111\n10000\n10000\n01110\n00001\n00001\n11110'

LETTERS[T]=$'11111\n00100\n00100\n00100\n00100\n00100\n00100'

LETTERS[U]=$'10001\n10001\n10001\n10001\n10001\n10001\n01110'

LETTERS[V]=$'10001\n10001\n10001\n10001\n10001\n01010\n00100'

LETTERS[W]=$'10001\n10001\n10001\n10101\n10101\n11011\n10001'

LETTERS[X]=$'10001\n10001\n01010\n00100\n01010\n10001\n10001'

LETTERS[Y]=$'10001\n10001\n01010\n00100\n00100\n00100\n00100'

LETTERS[Z]=$'11111\n00001\n00010\n00100\n01000\n10000\n11111'

LETTERS[.]=$'00000\n00000\n00000\n00000\n00000\n00100\n00000'

# Function to convert text to commit matrix
text_to_matrix() {
    local text="$1"
    local -a matrix=()
    local row col char letter_rows
    
    # Initialize empty matrix (7 rows)
    for ((row=0; row<7; row++)); do
        matrix[row]=""
    done
    
    # Process each character
    for ((i=0; i<${#text}; i++)); do
        char="${text:$i:1}"
        if [[ -n "${LETTERS[$char]}" ]]; then
            # Split the letter into rows
            IFS=$'\n' read -r -d '' -a letter_rows <<< "${LETTERS[$char]}"
            
            # Add each row of the letter
            for ((row=0; row<7; row++)); do
                matrix[row]+="${letter_rows[row]}"
                # Add space between letters (except for last letter)
                if ((i < ${#text}-1)); then
                    matrix[row]+="0"
                fi
            done
        fi
    done
    
    # Print resulting matrix
    for ((row=0; row<7; row++)); do
        echo "${matrix[row]}"
    done
}

# Function to convert matrix to commit dates
matrix_to_commits() {
    local text="$1"
    local start_date="$2"
    local -a commits=()
    local row col date intensity
    
    # Get the matrix
    local -a matrix=()
    while IFS= read -r line; do
        matrix+=($line)
    done < <(text_to_matrix "$text")
    
    # Convert matrix positions to commit dates
    for ((row=0; row<7; row++)); do
        for ((col=0; col<${#matrix[row]}; col++)); do
            if [[ "${matrix[row]:$col:1}" == "1" ]]; then
                # Calculate date (each column is a week, each row is a day)
                date=$(date -d "$start_date +$col week +$row day" +%Y-%m-%d)
                intensity=4  # Maximum intensity for filled squares
                commits+=("$date $intensity")
            fi
        done
    done
    
    # Return commits array
    echo "declare -a commits=("
    echo "    ${commits[*]}"
    echo ")"
}

# If script is run directly, handle command line arguments
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    if [[ "$1" == "text_to_matrix" && -n "$2" ]]; then
        text_to_matrix "$2"
    elif [[ "$1" == "matrix_to_commits" && -n "$2" && -n "$3" ]]; then
        matrix_to_commits "$2" "$3"
    fi
fi
