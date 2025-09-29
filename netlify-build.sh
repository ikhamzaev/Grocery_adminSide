#!/bin/bash

set -e

echo "🚀 Starting Flutter build process on Netlify..."

# Install Flutter
echo "📦 Installing Flutter..."
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
tar xf flutter_linux_3.24.5-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Verify Flutter installation
echo "✅ Verifying Flutter installation..."
flutter --version

# Enable web support
echo "🌐 Enabling Flutter web support..."
flutter config --enable-web

# Get dependencies
echo "📚 Getting Flutter dependencies..."
flutter pub get

# Build for web
echo "🔨 Building Flutter web app..."
flutter build web --release --web-renderer html

echo "✅ Build completed successfully!"
echo "📁 Build output directory: build/web"
