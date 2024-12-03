#!/bin/bash

# Check if both arguments are provided
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <input_settings_file> <exfiltration_directory>"
  exit 1
fi

# Assign arguments to variables
input_file="$1"
exfil_dir="$2"

# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
  echo "Error: Input settings file '$input_file' does not exist."
  exit 1
fi

# Check if the exfiltration directory exists, or create it
if [[ ! -d "$exfil_dir" ]]; then
  echo "Exfiltration directory '$exfil_dir' does not exist. Creating it..."
  mkdir -p "$exfil_dir" || { echo "Failed to create directory '$exfil_dir'"; exit 1; }
fi

# Get the current logged-in console user
currentUser=$(who | awk '/console/{print $1}')
echo "Current console user: $currentUser"

# Process each line in the input file
while IFS= read -r folder_path; do
  # Skip empty lines or lines starting with '#' (comments)
  [[ -z "$folder_path" || "$folder_path" =~ ^# ]] && continue

  echo "Processing folder: $folder_path"

  # Construct the source and destination paths
  src="$folder_path"
  dest="$exfil_dir${folder_path#/}" # Preserve relative folder structure in destination

  # Check if the source folder exists
  if [[ -d "$src" ]]; then
    echo "Copying from $src to $dest ..."
    mkdir -p "$(dirname "$dest")" # Ensure parent directories exist
    cp -r "$src" "$dest" || { echo "Failed to copy $src"; continue; }
    echo "Successfully copied $src to $dest"
  else
    echo "Warning: Source folder $src does not exist. Skipping..."
  fi
done < "$input_file"

echo "Exfiltration completed. Data is stored in $exfil_dir."
