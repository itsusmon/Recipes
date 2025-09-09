# Git Hooks

This directory contains git hooks for maintaining code quality in the project.

## Hooks

### pre-commit
- Runs `spotlessApply` on changed Kotlin files before each commit
- Automatically formats code according to project standards
- Adds formatted files back to staging area

### pre-push
- Runs `spotlessCheck` on the entire project before pushing
- Prevents pushing code that doesn't meet formatting standards
- Ensures consistent code style across the project

## Installation

To install these hooks, run the appropriate installation script for your operating system:

### Unix/Linux/macOS
```bash
./hooks/install.sh
```

### Windows
```cmd
hooks\install.bat
```

## Manual Installation

If you prefer to install the hooks manually, copy the hook files to your `.git/hooks` directory:

```bash
# From the project root directory
cp hooks/pre-commit .git/hooks/pre-commit
cp hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-commit .git/hooks/pre-push
```

## How It Works

1. **pre-commit**: When you commit changes, only the Kotlin files that are being committed will be formatted by Spotless. This is efficient and ensures that only relevant files are processed.

2. **pre-push**: When you push changes, the entire project is checked for formatting compliance. If any files don't meet the standards, the push will be rejected with instructions on how to fix the issues.

## Customization

The hooks use the project's Gradle configuration for Spotless, so any changes to formatting rules in `build.gradle.kts` will be automatically picked up by the hooks.

## Troubleshooting

If you encounter issues with the hooks:
1. Ensure Gradle is properly installed and accessible from the command line
2. Make sure the hook files have execute permissions (`chmod +x`)
3. Check that you're running the installation script from the project root directory