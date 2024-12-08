#!/bin/bash

# Function to display progress
echo_progress() {
    echo "🚀 $1"
}

# Function to check if directory exists before removing
safe_remove() {
    if [ -e "$1" ]; then
        rm -rf "$1"
        echo "✅ Removed: $1"
    fi
}

# Create backup
echo_progress "Creating backup..."
timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir="../interquatier_backup_$timestamp"
cp -r . "$backup_dir"
echo "✅ Backup created at: $backup_dir"

echo_progress "Starting cleanup..."

# Remove Android-specific directories and files
echo_progress "Removing Android files..."
safe_remove "app/src/main/java"
safe_remove "app/src/main/res"
safe_remove "app/src/main/AndroidManifest.xml"
safe_remove "app/build.gradle.kts"
safe_remove "gradle"
safe_remove "gradlew"
safe_remove "gradlew.bat"
safe_remove "settings.gradle.kts"
safe_remove "build.gradle.kts"

# Remove KMM directories
echo_progress "Removing KMM files..."
safe_remove "shared"

# Remove iOS native files
echo_progress "Removing iOS native files..."
safe_remove "iosApp"

# Remove Admin backend files
echo_progress "Removing Admin backend files..."
safe_remove "admin"

# Remove other unnecessary files
echo_progress "Removing miscellaneous files..."
safe_remove "ResizeIcon.kt"
safe_remove ".idea"
safe_remove ".gradle"

# Clean build directories
echo_progress "Cleaning build directories..."
safe_remove "build"
safe_remove "app/build"

# Verify Flutter structure
echo_progress "Verifying Flutter structure..."
required_dirs=("lib" "assets" "test")
required_files=("pubspec.yaml" "analysis_options.yaml")

for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "Created missing directory: $dir"
    fi
done

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "⚠️ Warning: Missing required file: $file"
    fi
done

echo_progress "Creating .gitignore if not exists..."
if [ ! -f ".gitignore" ]; then
    cat > .gitignore << EOL
# Flutter/Dart specific
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
*.iml

# Android specific
android/**/gradle-wrapper.jar
android/.gradle
android/captures/
android/gradlew
android/gradlew.bat
android/local.properties
android/GeneratedPluginRegistrant.java

# iOS specific
ios/Flutter/.last_build_id
ios/Flutter/Generated.xcconfig
ios/Flutter/flutter_export_environment.sh
ios/Flutter/Flutter.podspec
ios/.symlinks/
ios/Pods/

# VS Code specific
.vscode/

# IntelliJ/Android Studio
.idea/
*.iml
*.iws
*.ipr

# macOS specific
.DS_Store
EOL
    echo "Created .gitignore file"
fi

echo_progress "Cleanup complete! 🎉"
echo "Your project is now a clean Flutter project."
echo "Structure:"
echo "----------------------------------------"
ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//  /g' -e 's/^/  /'
echo "----------------------------------------"