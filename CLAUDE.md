# Lumina Project Guide

## Build & Test Commands
- Build: `xcodebuild -project Lumina.xcodeproj -scheme Lumina -configuration Debug build`
- Run app: `xcodebuild -project Lumina.xcodeproj -scheme Lumina -configuration Debug build run`
- Run all tests: `xcodebuild -project Lumina.xcodeproj -scheme Lumina -configuration Debug test`
- Run single test: `xcodebuild -project Lumina.xcodeproj -scheme Lumina -configuration Debug test -only-testing LuminaTests/LuminaTests/testName`

## Code Style Guidelines
- Use SwiftUI for all UI components
- Follow Swift standard 4-space indentation
- Include standard file headers with creation date
- Use Swift's new macro-based Testing framework for unit tests
- Group code by feature in the directory structure
- Use `#Preview` macro for SwiftUI previews
- Use descriptive variable names in camelCase
- Prefer Swift's strong typing system and avoid force unwrapping
- Use Swift async/await for error handling and async code
- Keep functions small and single-purpose

## UI and UX
- When Building any UI, use context7 to search up the Human Interface Guidelines
- The UI should be modern and simple

## Thinking
- Take your time. Don't jump to conclusions.

