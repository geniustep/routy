#!/bin/bash

echo "========================================"
echo "   Flutter Web - Simple Version"
echo "========================================"

# Create temp directory for Chrome
mkdir -p /tmp/chrome_dev_test

# Kill any existing Chrome processes
echo "Killing existing Chrome processes..."
pkill -f chrome 2>/dev/null || true

# Wait a moment
sleep 2

# Run Flutter web with simple Chrome settings
echo "Starting Flutter Web..."
flutter run -d chrome --web-browser-flag="--disable-web-security" --web-browser-flag="--user-data-dir=/tmp/chrome_dev_test"

echo ""
echo "========================================"
echo "   Flutter Web session ended"
echo "========================================"
read -p "Press any key to continue..."
