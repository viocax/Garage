#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting deployment for Garage Marketing Web..."

# Configuration
GITHUB_PAGES_REPO="https://github.com/drakehuang81/drakehuang81.github.io.git"
SUBDIRECTORY="garage"
BASE_HREF="/${SUBDIRECTORY}/"

# Check if we are in the right directory
if [ ! -d "marketing_web" ]; then
  echo "❌ Error: Please run this script from the root of the 'garage' project."
  echo "Current directory: $(pwd)"
  exit 1
fi

# --- Build Process ---
echo "📦 Building Flutter Web..."
cd marketing_web

# Ensure dependencies are installed
flutter pub get

# Build with the correct base-href for the subdirectory
flutter build web --base-href "${BASE_HREF}" --release

if [ ! -d "build/web" ]; then
  echo "❌ Build failed: 'build/web' directory not found."
  exit 1
fi

echo "✅ Build completed successfully!"

# Store the path to the build output
BUILD_PATH=$(pwd)/build/web

# Go back to the project root
cd ..

# --- Deploy Process ---
echo "📤 Preparing to deploy to GitHub Pages..."

# Create a temporary directory for cloning
TEMP_DIR=$(mktemp -d)
echo "📁 Using temporary directory: ${TEMP_DIR}"

# Cleanup function to remove temp directory on exit
cleanup() {
  echo "🧹 Cleaning up temporary files..."
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

# Clone the GitHub Pages repository
echo "📥 Cloning ${GITHUB_PAGES_REPO}..."
git clone --depth 1 "${GITHUB_PAGES_REPO}" "${TEMP_DIR}/pages"

cd "${TEMP_DIR}/pages"

# Remove the old subdirectory content if it exists
if [ -d "${SUBDIRECTORY}" ]; then
  echo "🗑️  Removing old ${SUBDIRECTORY}/ content..."
  rm -rf "${SUBDIRECTORY}"
fi

# Create the subdirectory and copy the build
echo "📋 Copying build to ${SUBDIRECTORY}/..."
mkdir -p "${SUBDIRECTORY}"
cp -R "${BUILD_PATH}/"* "${SUBDIRECTORY}/"

# Commit and push
echo "📝 Committing changes..."
git add .
git commit -m "Deploy garage marketing site: $(date '+%Y-%m-%d %H:%M:%S')" || {
  echo "ℹ️  No changes to commit. Site is already up to date."
  exit 0
}

echo "🚀 Pushing to GitHub..."
git push origin main

echo "--------------------------------------------------------"
echo "✅ Deployed successfully!"
echo "🌎 Your site should be live at: https://drakehuang81.github.io/${SUBDIRECTORY}/"
echo "(Note: It might take a minute or two for GitHub to update)"
echo "--------------------------------------------------------"
