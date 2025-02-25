#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
CONFIGURATION="Debug"
DESTINATION="platform=iOS Simulator,name=iPhone 16"
ACTION="build"
CLEAN=false
VERBOSE=false

# Help function
function show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -s, --scheme <scheme>        Build scheme (required)"
    echo "  -c, --configuration <config>  Build configuration (Debug/Release, default: Debug)"
    echo "  -d, --destination <dest>      Build destination (default: platform=iOS Simulator,name=iPhone 16)"
    echo "  -a, --action <action>        Build action (build/test/clean, default: build)"
    echo "  --clean                      Clean build folder before building"
    echo "  -v, --verbose                Show verbose output"
    echo "  -h, --help                   Show this help message"
    echo
    echo "Available schemes:"
    echo "Core frameworks and services:"
    echo "  - ServicesProvider"
    echo "  - SharedModels"
    echo "  - DictionaryCoding"
    echo "  - Extensions"
    echo "  - GomaAssets"
    echo "  - Theming"
    echo
    echo "Features and UI components:"
    echo "  - HeaderTextField"
    echo "  - CountrySelectionFeature"
    echo "  - RegisterFlow"
    echo "  - AdresseFrancaise"
    echo "  - NotificationsService"
    echo
    echo "Sports data providers:"
    echo "  - SportRadar PROD"
    echo "  - SportRadar UAT"
    echo "  - GomaSportRadar"
    echo
    echo "Client applications:"
    echo "  - ATP"
    echo "  - Betsson PROD"
    echo "  - Betsson UAT"
    echo "  - Crocobet"
    echo "  - DAZN"
    echo "  - EveryMatrix"
    echo "  - GOMASports"
    echo
    echo "Tests:"
    echo "  - SportsbookTests"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--scheme)
            SCHEME="$2"
            shift 2
            ;;
        -c|--configuration)
            CONFIGURATION="$2"
            shift 2
            ;;
        -d|--destination)
            DESTINATION="$2"
            shift 2
            ;;
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if scheme is provided
if [ -z "$SCHEME" ]; then
    echo -e "${RED}Error: Scheme is required${NC}"
    show_help
    exit 1
fi

# Function to clean DerivedData
function clean_derived_data() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${YELLOW}Cleaning DerivedData...${NC}"
    fi
    rm -rf ~/Library/Developer/Xcode/DerivedData/*
}

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: xcodebuild command not found${NC}"
    exit 1
fi

# Clean if requested
if [ "$CLEAN" = true ]; then
    clean_derived_data
fi

# Build command construction
BUILD_CMD="xcodebuild"
BUILD_CMD+=" -project Sportsbook.xcodeproj"
BUILD_CMD+=" -scheme $SCHEME"
BUILD_CMD+=" -configuration $CONFIGURATION"
BUILD_CMD+=" -destination \"$DESTINATION\""

# Add important build settings from the actual build
BUILD_CMD+=" SWIFT_VERSION=5"
BUILD_CMD+=" IPHONEOS_DEPLOYMENT_TARGET=13.0"
BUILD_CMD+=" ENABLE_TESTING=YES"
BUILD_CMD+=" DEBUG_INFORMATION_FORMAT=dwarf"
BUILD_CMD+=" SWIFT_OPTIMIZATION_LEVEL=-Onone"
BUILD_CMD+=" GCC_OPTIMIZATION_LEVEL=0"
BUILD_CMD+=" ENABLE_BITCODE=NO"

# Execute the build
echo -e "${YELLOW}Building $SCHEME ($CONFIGURATION)...${NC}"

if [ "$VERBOSE" = true ]; then
    echo "Build command: $BUILD_CMD"
    eval "$BUILD_CMD $ACTION"
else
    # Suppress all output except errors and warnings
    eval "$BUILD_CMD $ACTION" 2>&1 | grep -E "error:|warning:|fatal error:" || true
fi

BUILD_RESULT=$?

if [ $BUILD_RESULT -eq 0 ]; then
    echo -e "${GREEN}✓ Build succeeded${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
fi

exit $BUILD_RESULT