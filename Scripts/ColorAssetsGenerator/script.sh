#!/bin/bash

# Read the CSV file with the list of colors
while IFS=',' read -r colorName lightTheme darkTheme; do
  # Create the folder structure for each color
  mkdir -p "Output/${colorName}.colorset"

  # Create the Contents.json file for each color
  cat > "Output/${colorName}.colorset/Contents.json" << EOF
{
  "info": {
    "version": 1,
    "author": "xcode"
  },
  "colors": [
    {
      "idiom": "universal",
      "color": {
        "color-space": "srgb",
        "components": {
          "red": "$(echo $lightTheme | cut -c2-3 | xxd -p -r | hexdump -v -e '1/1 "%.2X"')",
          "green": "$(echo $lightTheme | cut -c4-5 | xxd -p -r | hexdump -v -e '1/1 "%.2X"')",
          "blue": "$(echo $lightTheme | cut -c6-7 | xxd -p -r | hexdump -v -e '1/1 "%.2X"')",
          "alpha": "FF"
        }
      },
      " appearances": [
        {
          "appearance": "luminosity",
          "value": "light"
        }
      ]
    },
    {
      "idiom": "universal",
      "color": {
        "color-space": "srgb",
        "components": {
          "red": "$(echo $darkTheme | cut -c2-3 | xxd -p -r | hexdump -v -e '1/1 "%.2X"')",
          "green": "$(echo $darkTheme | cut -c4-5 | xxd -p -r | hexdump -v -e '1/1 "%.2X"')",
          "blue": "$(echo $darkTheme | cut -c6-7 | xxd -p -r | hexdump -v -e '1/1 "%.2X"')",
          "alpha": "FF"
        }
      },
      " appearances": [
        {
          "appearance": "luminosity",
          "value": "dark"
        }
      ]
    }
  ]
}
EOF

done < colors.csv
