#!/bin/bash

echo "Starting Flutter Web with CORS settings..."

# Create temp directory for Chrome
mkdir -p /tmp/chrome_dev_test

# Kill any existing Chrome processes
pkill -f chrome 2>/dev/null || true

# Wait a moment
sleep 2

# Run Flutter web with specific Chrome settings
echo "Running Flutter Web..."
flutter run -d chrome --web-browser-flag="--disable-web-security" --web-browser-flag="--disable-features=VizDisplayCompositor" --web-browser-flag="--user-data-dir=/tmp/chrome_dev_test" --web-browser-flag="--allow-running-insecure-content"

echo "Press any key to continue..."
read -n 1 -s
