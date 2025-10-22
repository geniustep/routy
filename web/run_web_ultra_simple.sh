#!/bin/bash

echo "========================================"
echo "   Flutter Web - Ultra Simple"
echo "========================================"

# Kill any existing Chrome processes
echo "Killing existing Chrome processes..."
pkill -f chrome 2>/dev/null || true

# Wait a moment
sleep 2

# Run Flutter web with minimal Chrome settings
echo "Starting Flutter Web..."
flutter run -d chrome --web-browser-flag="--disable-web-security"

echo ""
echo "========================================"
echo "   Flutter Web session ended"
echo "========================================"
read -p "Press any key to continue..."
