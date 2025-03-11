#!/bin/zsh

# Read the entire stdin input
input=$(cat)

# Debug: Show raw input
echo "Received input: '$input'" >&2

# Extract image path (first line) and caption (rest)
imageVar=$(echo "$input" | head -n 1)  # First line
textVar=$(echo "$input" | tail -n +2)  # Remaining lines

# Debug output
echo "Image Path: '$imageVar'" >&2
echo "Caption Text: '$textVar'" >&2

# Check if values are missing
if [[ -z "$imageVar" || -z "$textVar" ]]; then
  echo "Error: Missing required inputs." >&2
  exit 1
fi

# Convert to JSON for Node.js script
json_input="{\"imagePath\":\"$imageVar\", \"captionText\":\"$textVar\"}"

# Run Node.js script

echo "$json_input" | node /Users/data/Scripts/color-swatches/add_caption.js
