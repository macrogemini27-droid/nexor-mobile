#!/bin/bash

# Phase 3 Build Script
# This script generates all necessary .g.dart files for Phase 3

echo "🚀 Starting Phase 3 code generation..."

cd "$(dirname "$0")"

echo "📦 Installing dependencies..."
flutter pub get

echo "🔨 Running build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "✅ Code generation complete!"
echo ""
echo "Generated files:"
echo "  - lib/data/models/session/session_model.g.dart"
echo "  - lib/data/models/session/message_model.g.dart"
echo "  - lib/presentation/screens/chat/providers/conversations_provider.g.dart"
echo "  - lib/presentation/screens/chat/providers/chat_provider.g.dart"
echo ""
echo "🎉 Phase 3 is ready to run!"
