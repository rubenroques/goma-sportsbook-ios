#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get configuration from argument or use default
CONFIGURATION=${1:-Debug}

# Array of schemes to build in order
SCHEMES=(
    # Core frameworks and services
    "ServicesProvider"
    "SharedModels"
    "DictionaryCoding"
    "Extensions"
    "GomaAssets"
    "Theming"

    # Features and UI components
    "HeaderTextField"
    "CountrySelectionFeature"
    "RegisterFlow"
    "AdresseFrancaise"
    "NotificationsService"

    # Client applications
    "SportRadar PROD"
    "SportRadar UAT"
    "GomaSportRadar"
    "ATP"
    "Betsson PROD"
    "Betsson UAT"
    "Crocobet"
    "DAZN"
    "EveryMatrix"
    "GOMASports"

    # Tests
    "SportsbookTests"
)

# Function to build a scheme
function build_scheme() {
    local scheme=$1
    echo -e "${YELLOW}Building $scheme...${NC}"

    ./build.sh --scheme "$scheme" --configuration "$CONFIGURATION"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully built $scheme${NC}"
        return 0
    else
        echo -e "${RED}Failed to build $scheme${NC}"
        return 1
    fi
}

# Make build.sh executable
chmod +x build.sh

# Clean DerivedData before starting
echo -e "${YELLOW}Cleaning DerivedData...${NC}"
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Build frameworks first
echo -e "${YELLOW}Building frameworks...${NC}"
build_scheme "ServicesProvider" || exit 1
build_scheme "SharedModels" || exit 1

# Build client applications
echo -e "${YELLOW}Building client applications...${NC}"
for scheme in "${SCHEMES[@]}"; do
    # Skip already built frameworks
    if [[ "$scheme" != "ServicesProvider" && "$scheme" != "SharedModels" ]]; then
        build_scheme "$scheme" || exit 1
    fi
done

echo -e "${GREEN}All builds completed successfully!${NC}"