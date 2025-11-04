#!/bin/bash

output_file="${USER}_app_summary.json"
timestamp=$(date +"%Y-%m-%d %H:%M:%S") # local time

# Find all .app bundles under /Users
apps=$(find /Users -type d -iname "*.app" -prune 2>/dev/null)

# Start JSON structure
json="{\"Timestamp\": \"${timestamp}\", \"Apps\": {"
first_entry=true

while IFS= read -r app; do
  app_name=$(basename "$app" .app)
  app_dir="$(dirname "$app")/"
  info_plist="$app/Contents/Info.plist"

  if [[ -f "$info_plist" ]]; then
    exe=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "$info_plist" 2>/dev/null)
    exe_loc="Contents/MacOS/$exe"

    if [[ -n "$exe" && -x "$app/$exe_loc" ]]; then
      # Add comma between entries (after the first one)
      if [ "$first_entry" = true ]; then
        first_entry=false
      else
        json+=","
      fi

      json+="
      \"${app_name}\": {
        \"AppDir\": \"${app_dir}\",
        \"AppLoc\": \"$(basename "$app")\",
        \"ExeLoc\": \"${exe_loc}\"
      }"
    fi
  fi
done <<< "$apps"

# Close JSON
json+="
  }
}"

# Save to file
echo "$json" > "$output_file"

# Optional: pretty-print with jq if installed
if command -v jq >/dev/null 2>&1; then
  jq . "$output_file" > "${output_file}.tmp" && mv "${output_file}.tmp" "$output_file"
fi

echo "Summary saved to: $output_file"