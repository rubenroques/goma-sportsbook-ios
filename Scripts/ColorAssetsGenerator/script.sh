#!/bin/bash

# Read the CSV file with the list of colors
while IFS=',' read -r colorName lightTheme darkTheme || [[ -n "$colorName" ]]; do
  # Create the folder structure for each color
  mkdir -p "Colors.xcassets/${colorName}.colorset"

  echo "${colorName}" 

  # Create the Contents.json file for each color
  cat > "Colors.xcassets/${colorName}.colorset/Contents.json" << EOF
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "red": "0x$(echo $darkTheme | cut -c2-3)",
          "green": "0x$(echo $darkTheme | cut -c4-5)",
          "blue": "0x$(echo $darkTheme | cut -c6-7)",
        }
      },
      "idiom" : "universal"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "red": "0x$(echo $lightTheme | cut -c2-3)",
          "green": "0x$(echo $lightTheme | cut -c4-5)",
          "blue": "0x$(echo $lightTheme | cut -c6-7)",
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

done < colors.csv
