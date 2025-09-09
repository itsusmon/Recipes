@echo off

REM Install git hooks script for Windows

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0

REM Get the project root directory (parent of hooks directory)
for %%i in ("%SCRIPT_DIR%..") do set "PROJECT_ROOT=%%~fi"

REM Get the git hooks directory
set "GIT_HOOKS_DIR=%PROJECT_ROOT%\.git\hooks"

REM Check if .git directory exists
if not exist "%GIT_HOOKS_DIR%" (
    echo Error: .git\hooks directory not found!
    echo Please make sure you're running this script from a git repository.
    exit /b 1
)

echo Installing git hooks...

REM Copy the hooks to the .git\hooks directory
copy "%SCRIPT_DIR%pre-commit" "%GIT_HOOKS_DIR%\pre-commit"
copy "%SCRIPT_DIR%pre-push" "%GIT_HOOKS_DIR%\pre-push"

echo Git hooks installed successfully!
echo Hooks installed to: %GIT_HOOKS_DIR%

pause