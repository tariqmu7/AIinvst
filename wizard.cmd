@echo off
title Fund Master Deployment Wizard
color 0B

echo ========================================================
echo       FUND MASTER - FRESH DEPLOYMENT WIZARD
echo ========================================================
echo.
echo This script will REPAIR missing configuration files, reset Git,
echo and FORCE deploy your site.
echo.

:: --- Step 1: Gather Information ---
:ASK_REPO
set /p "repoUrl=Paste your GitHub Repository URL (e.g., https://github.com/tariqmu7/AIinvst.git): "
if "%repoUrl%"=="" goto ASK_REPO

:ASK_NAME
set /p "repoName=Enter your Repository Name (e.g., AIinvst): "
if "%repoName%"=="" goto ASK_NAME

:ASK_MSG
set /p "commitMsg=Enter a message for this update (e.g., Fresh Start): "
if "%commitMsg%"=="" goto ASK_MSG

:: --- Step 2: Fix Windows Git Permissions ---
echo.
echo [1/8] Configuring Git permissions...
git config --global --add safe.directory "%cd%"

:: --- Step 3: Repair Configuration Files ---
echo.
echo [2/8] Repairing Project Configuration...

:: 3a. Re-initialize package.json if broken/missing
call npm init -y
call npm pkg set type="module"
call npm pkg set scripts.dev="vite"
call npm pkg set scripts.build="vite build"
call npm pkg set scripts.preview="vite preview"
call npm pkg set scripts.predeploy="npm run build"
call npm pkg set scripts.deploy="gh-pages -d dist"

:: 3b. Create vite.config.js
echo.
echo Generating vite.config.js...
(
echo import { defineConfig } from 'vite'
echo import react from '@vitejs/plugin-react'
echo.
echo export default defineConfig({
echo   plugins: [react^(^)],
echo   base: '/%repoName%/',
echo })
) > vite.config.js

:: 3c. Create index.html (Vital for build)
echo.
echo Generating index.html...
(
echo ^<!doctype html^>
echo ^<html lang="en"^>
echo   ^<head^>
echo     ^<meta charset="UTF-8" /^>
echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0" /^>
echo     ^<title^>Fund Master^</title^>
echo     ^<script src="https://cdn.tailwindcss.com"^>^</script^>
echo   ^</head^>
echo   ^<body^>
echo     ^<div id="root"^>^</div^>
echo     ^<script type="module" src="/src/main.jsx"^>^</script^>
echo   ^</body^>
echo ^</html^>
) > index.html

:: 3d. Ensure src/main.jsx exists (Wrapper)
if not exist "src\main.jsx" (
    echo Generating src/main.jsx...
    if not exist "src" mkdir src
    (
    echo import React from 'react'
    echo import ReactDOM from 'react-dom/client'
    echo import App from './App.jsx'
    echo import './index.css'
    echo.
    echo ReactDOM.createRoot(document.getElementById('root'^)^).render(
    echo   ^<React.StrictMode^>
    echo     ^<App /^>
    echo   ^</React.StrictMode^>,
    echo ^)
    ) > src\main.jsx
)

:: 3e. Ensure src/index.css exists
if not exist "src\index.css" (
    echo Generating src/index.css...
    (
    echo @tailwind base;
    echo @tailwind components;
    echo @tailwind utilities;
    echo.
    echo :root { font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif; line-height: 1.5; font-weight: 400; color-scheme: dark; }
    echo body { margin: 0; padding: 0; min-width: 320px; min-height: 100vh; background-color: #030712; }
    echo #root { width: 100%%; min-height: 100vh; display: flex; flex-direction: column; }
    ) > src\index.css
)

:: --- Step 4: Install Dependencies ---
echo.
echo [3/8] Installing Dependencies (This may take a moment)...
call npm install vite @vitejs/plugin-react react react-dom firebase lucide-react gh-pages --save-dev

:: --- Step 5: Reset Git ---
echo.
echo [4/8] Configuring Repository Connection...
if exist .git (
    rmdir /s /q .git
)
git init
git remote add origin %repoUrl%
git branch -M main

:: --- Step 6: Save and Upload Source Code ---
echo.
echo [5/8] Uploading Source Code (Force Push)...
git add .
git commit -m "%commitMsg%"
git push -u origin main --force

:: --- Step 7: Build Site ---
echo.
echo [6/8] Building the Application...
call npm run build

:: --- Step 8: Publish to GitHub Pages ---
echo.
echo [7/8] Publishing to GitHub Pages...
if exist dist (
    call npx gh-pages -d dist
    echo.
    echo [8/8] Success!
    echo.
    echo ========================================================
    echo                 DEPLOYMENT COMPLETE!
    echo ========================================================
    echo.
    echo 1. Wait about 2-5 minutes for GitHub to process.
    echo 2. Your site will be at: https://tariqmu7.github.io/%repoName%/
) else (
    echo.
    echo [ERROR] Build failed. 'dist' folder was not created.
    echo Please check the error messages above.
)

echo.
pause