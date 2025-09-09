#!/usr/bin/env bash

# Install git hooks script for Unix/Linux/macOS

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the project root directory (parent of hooks directory)
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Get the git hooks directory
GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

# Check if .git directory exists
if [ ! -d "$GIT_HOOKS_DIR" ]; then
    echo "Error: .git/hooks directory not found!"
    echo "Please make sure you're running this script from a git repository."
    exit 1
fi

echo "Installing git hooks..."

# Copy the hooks to the .git/hooks directory
cp "$SCRIPT_DIR/pre-commit" "$GIT_HOOKS_DIR/pre-commit"
cp "$SCRIPT_DIR/pre-push" "$GIT_HOOKS_DIR/pre-push"

# Make the hooks executable
chmod +x "$GIT_HOOKS_DIR/pre-commit"
chmod +x "$GIT_HOOKS_DIR/pre-push"

echo "Git hooks installed successfully!"
echo "Hooks installed to: $GIT_HOOKS_DIR"