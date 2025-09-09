#!/bin/bash

# increment - Version increment script for gradle.properties
# Usage: increment [--major|--minor|--patch] [--gradle-file <path>] [--ios-file <path>]

set -e  # Exit on any error

# Default file paths
GRADLE_PROPERTIES="gradle.properties"
XCCONFIG_FILE="iosApp/Configuration/Config.xcconfig"

# Function to get current version value and validate from gradle.properties
get_gradle_version() {
    local key=$1
    local line=$(grep "^${key}=" "$GRADLE_PROPERTIES" 2>/dev/null || true)

    if [ -z "$line" ]; then
        echo "Error: '$key' not found in $GRADLE_PROPERTIES"
        echo "Please ensure your gradle.properties contains: $key=<value>"
        exit 1
    fi

    local value=$(echo "$line" | cut -d'=' -f2)

    # Check if value is empty
    if [ -z "$value" ]; then
        echo "Error: '$key' has no value in $GRADLE_PROPERTIES"
        echo "Expected format: $key=<value>"
        exit 1
    fi

    echo "$value"
}

# Function to get iOS config values (returns empty if file doesn't exist or key not found)
get_ios_version() {
    local key=$1
    if [ ! -f "$XCCONFIG_FILE" ]; then
        echo ""
        return
    fi

    local line=$(grep "^${key} = " "$XCCONFIG_FILE" 2>/dev/null || true)
    if [ -z "$line" ]; then
        echo ""
        return
    fi

    local value=$(echo "$line" | cut -d'=' -f2 | sed 's/^ *//' | sed 's/ *$//')
    echo "$value"
}

# Function to compare and get the higher version code
get_higher_version_code() {
    local gradle_code=$(get_gradle_version "version.code")
    local ios_code=$(get_ios_version "CURRENT_PROJECT_VERSION")

    # Validate gradle version.code is integer
    if ! [[ "$gradle_code" =~ ^[0-9]+$ ]]; then
        echo "Error: 'version.code' value '$gradle_code' is not a valid integer in $GRADLE_PROPERTIES"
        echo "Expected format: version.code=<number> (e.g., version.code=1)"
        exit 1
    fi

    # If iOS file doesn't exist or doesn't have the value, use gradle value
    if [ -z "$ios_code" ]; then
        echo "$gradle_code gradle"
        return
    fi

    # Validate iOS version code is integer
    if ! [[ "$ios_code" =~ ^[0-9]+$ ]]; then
        echo "Warning: iOS CURRENT_PROJECT_VERSION '$ios_code' is not a valid integer, using gradle value"
        echo "$gradle_code gradle"
        return
    fi

    # Return the higher value and its source
    if [ "$ios_code" -gt "$gradle_code" ]; then
        echo "$ios_code ios"
    elif [ "$gradle_code" -gt "$ios_code" ]; then
        echo "$gradle_code gradle"
    else
        echo "$gradle_code both"
    fi
}

# Function to compare semantic versions (returns 1 if v1 > v2, 0 if equal, -1 if v1 < v2)
compare_semantic_versions() {
    local v1=$1
    local v2=$2

    IFS='.' read -r v1_major v1_minor v1_patch <<< "$v1"
    IFS='.' read -r v2_major v2_minor v2_patch <<< "$v2"

    # Compare major
    if [ "$v1_major" -gt "$v2_major" ]; then
        echo 1
        return
    elif [ "$v1_major" -lt "$v2_major" ]; then
        echo -1
        return
    fi

    # Compare minor
    if [ "$v1_minor" -gt "$v2_minor" ]; then
        echo 1
        return
    elif [ "$v1_minor" -lt "$v2_minor" ]; then
        echo -1
        return
    fi

    # Compare patch
    if [ "$v1_patch" -gt "$v2_patch" ]; then
        echo 1
        return
    elif [ "$v1_patch" -lt "$v2_patch" ]; then
        echo -1
        return
    else
        echo 0
        return
    fi
}

# Function to get the higher semantic version
get_higher_version_name() {
    local gradle_name=$(get_gradle_version "version.name")
    local ios_name=$(get_ios_version "MARKETING_VERSION")

    # Validate gradle version.name format
    if ! [[ "$gradle_name" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: 'version.name' value '$gradle_name' is not in valid semantic version format"
        echo "Expected format: version.name=<major>.<minor>.<patch> (e.g., version.name=1.0.0)"
        exit 1
    fi

    # If iOS file doesn't exist or doesn't have the value, use gradle value
    if [ -z "$ios_name" ]; then
        echo "$gradle_name gradle"
        return
    fi

    # Validate iOS version name format
    if ! [[ "$ios_name" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Warning: iOS MARKETING_VERSION '$ios_name' is not in valid semantic version format, using gradle value"
        echo "$gradle_name gradle"
        return
    fi

    # Compare versions
    local comparison=$(compare_semantic_versions "$ios_name" "$gradle_name")
    if [ "$comparison" -eq 1 ]; then
        echo "$ios_name ios"
    elif [ "$comparison" -eq -1 ]; then
        echo "$gradle_name gradle"
    else
        echo "$gradle_name both"
    fi
}

# Function to update version value (only touches the specific line)
update_version() {
    local key=$1
    local value=$2
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - only replace the specific line with the key
        sed -i '' "/^${key}=/s/.*/${key}=${value}/" "$GRADLE_PROPERTIES"
    else
        # Linux - only replace the specific line with the key
        sed -i "/^${key}=/s/.*/${key}=${value}/" "$GRADLE_PROPERTIES"
    fi
}

# Parse command line arguments
version_type="patch"
while [[ $# -gt 0 ]]; do
    case $1 in
        --major|-M|major)
            version_type="major"
            shift
            ;;
        --minor|-m|minor)
            version_type="minor"
            shift
            ;;
        --patch|-p|patch)
            version_type="patch"
            shift
            ;;
        --gradle-file|-g)
            if [[ -n "$2" && "$2" != --* && "$2" != -* ]]; then
                GRADLE_PROPERTIES="$2"
                shift 2
            else
                echo "Error: --gradle-file/-g requires a file path"
                exit 1
            fi
            ;;
        --ios-file|-i)
            if [[ -n "$2" && "$2" != --* && "$2" != -* ]]; then
                XCCONFIG_FILE="$2"
                shift 2
            else
                echo "Error: --ios-file/-i requires a file path"
                exit 1
            fi
            ;;
        --help|-h)
            echo "Usage: increment [OPTIONS]"
            echo ""
            echo "Version Options:"
            echo "  --major, -M    Increment major version, reset minor and patch to 0"
            echo "  --minor, -m    Increment minor version, reset patch to 0"
            echo "  --patch, -p    Increment patch version (default)"
            echo ""
            echo "File Options:"
            echo "  --gradle-file, -g <path>  Path to gradle.properties file (default: gradle.properties)"
            echo "  --ios-file, -i <path>     Path to iOS config file (default: iosApp/Configuration/Config.xcconfig)"
            echo ""
            echo "Other Options:"
            echo "  --help, -h     Show this help message"
            echo ""
            echo "Always increments version.code by 1"
            echo ""
            echo "Expected gradle.properties format:"
            echo "  version.code=<number>"
            echo "  version.name=<major>.<minor>.<patch>"
            echo ""
            echo "Examples:"
            echo "  increment                     # Increment patch version"
            echo "  increment -m                  # Increment minor version"
            echo "  increment -M -g build.gradle.properties"
            echo "  increment -p -i MyApp/Config.xcconfig"
            echo "  increment --major -g config/version.properties -i ios/Config.xcconfig"
            exit 0
            ;;
        *)
            echo "Error: Unknown option '$1'"
            echo "Use 'increment --help' for usage information"
            exit 1
            ;;
    esac
done

# Check if gradle.properties exists
if [ ! -f "$GRADLE_PROPERTIES" ]; then
    echo "Error: Gradle properties file not found: $GRADLE_PROPERTIES"
    exit 1
fi

echo "Using Gradle properties file: $GRADLE_PROPERTIES"
if [ -f "$XCCONFIG_FILE" ]; then
    echo "Using iOS config file: $XCCONFIG_FILE"
else
    echo "iOS config file will be checked at: $XCCONFIG_FILE"
fi
echo ""

# Get and validate current versions from both files
echo "Validating version properties..."

# Get the higher version code
version_code_result=$(get_higher_version_code)
current_code=$(echo "$version_code_result" | cut -d' ' -f1)
code_source=$(echo "$version_code_result" | cut -d' ' -f2)

# Get the higher version name
version_name_result=$(get_higher_version_name)
current_name=$(echo "$version_name_result" | cut -d' ' -f1)
name_source=$(echo "$version_name_result" | cut -d' ' -f2)

# Parse version.name into components
IFS='.' read -r current_major current_minor current_patch <<< "$current_name"

echo "Current version: ${current_name} (code: ${current_code})"
echo "  version.name source: ${name_source}"
echo "  version.code source: ${code_source}"

# Determine version increment based on parsed arguments
case "$version_type" in
    major)
        new_code=$((current_code + 1))
        new_major=$((current_major + 1))
        new_minor=0
        new_patch=0
        echo "Incrementing MAJOR version..."
        ;;
    minor)
        new_code=$((current_code + 1))
        new_major=$current_major
        new_minor=$((current_minor + 1))
        new_patch=0
        echo "Incrementing MINOR version..."
        ;;
    patch)
        new_code=$((current_code + 1))
        new_major=$current_major
        new_minor=$current_minor
        new_patch=$((current_patch + 1))
        echo "Incrementing PATCH version..."
        ;;
esac

# Create new version name
new_name="${new_major}.${new_minor}.${new_patch}"

# Update the gradle.properties file
update_version "version.code" "$new_code"
update_version "version.name" "$new_name"

echo "New version: ${new_name} (code: ${new_code})"
echo "✓ gradle.properties updated successfully!"

# Update iOS configuration file if it exists
if [ -f "$XCCONFIG_FILE" ]; then
    echo "✓ iOS config file found: $XCCONFIG_FILE"

    # Update the iOS config file
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "/^MARKETING_VERSION = /s/.*/MARKETING_VERSION = ${new_name}/" "$XCCONFIG_FILE"
        sed -i '' "/^CURRENT_PROJECT_VERSION = /s/.*/CURRENT_PROJECT_VERSION = ${new_code}/" "$XCCONFIG_FILE"
    else
        # Linux
        sed -i "/^MARKETING_VERSION = /s/.*/MARKETING_VERSION = ${new_name}/" "$XCCONFIG_FILE"
        sed -i "/^CURRENT_PROJECT_VERSION = /s/.*/CURRENT_PROJECT_VERSION = ${new_code}/" "$XCCONFIG_FILE"
    fi

    # Verify the update was successful by checking if the lines exist with new values
    if grep -q "^MARKETING_VERSION = ${new_name}$" "$XCCONFIG_FILE" && grep -q "^CURRENT_PROJECT_VERSION = ${new_code}$" "$XCCONFIG_FILE"; then
        echo "✓ iOS config file updated successfully!"
        echo "  MARKETING_VERSION = ${new_name}"
        echo "  CURRENT_PROJECT_VERSION = ${new_code}"
    else
        echo "⚠ Warning: iOS config file update may have failed. Please verify manually."
        echo "  Expected: MARKETING_VERSION = ${new_name}"
        echo "  Expected: CURRENT_PROJECT_VERSION = ${new_code}"
    fi
else
    echo "ℹ iOS config file not found: $XCCONFIG_FILE (skipping iOS update)"
fi
