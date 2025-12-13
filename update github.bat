@echo off
title Fund Master Auto-Updater
color 0A

:: --- Fix Git Permissions (Dubious Ownership) ---
:: This allows Git to run in this folder even if Windows permissions are tricky
git config --global --add safe.directory "%cd%"

echo ========================================================
echo          FUND MASTER GITHUB UPDATER
echo ========================================================
echo.

:: --- Check for Git Repository ---
if not exist .git (
    echo [INFO] Initializing Git repository...
    git init
)

:: --- Check for Remote Origin ---
:: We assume origin exists to avoid errors. If push fails, we ask for URL.
git remote get-url origin >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [WARNING] No GitHub remote found!
    echo Please paste your GitHub Repository URL below.
    echo (Example: https://github.com/YourUsername/fund-master.git)
    echo.
    set /p "repoUrl=Repository URL: "
    git remote add origin %repoUrl%
)

:: --- Step 1: Input Commit Message ---
:PROMPT
set /p "commitMsg=Enter a description of your changes: "
if "%commitMsg%"=="" goto PROMPT

echo.
echo --------------------------------------------------------
echo [1/4] Staging files...
echo --------------------------------------------------------
git add .

echo.
echo --------------------------------------------------------
echo [2/4] Saving to local history...
echo --------------------------------------------------------
git commit -m "%commitMsg%"

echo.
echo --------------------------------------------------------
echo [3/4] Syncing with GitHub...
echo --------------------------------------------------------
echo Pulling latest changes from remote...
:: FIXED: Added --allow-unrelated-histories to merge local and remote projects
git pull origin HEAD --allow-unrelated-histories --no-edit

echo.
echo Uploading source code...
:: Pushes the current branch (HEAD) to the remote, works for master, main, or gh-pages
git push origin HEAD

echo.
echo --------------------------------------------------------
echo [4/4] Building and Deploying to Live Site...
echo --------------------------------------------------------
call npm run deploy

echo.
echo ========================================================
echo                 SUCCESS! SITE UPDATED.
echo ========================================================
echo You can close this window.
pause