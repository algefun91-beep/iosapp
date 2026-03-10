# SimpleApp — SwiftUI Counter

A minimal SwiftUI macOS app with a GitHub Actions CI workflow.

## Features
- Increment / decrement counter
- Reset button
- macOS 13+ compatible

## Project Structure
```
SimpleApp/
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions CI
├── SimpleApp.xcodeproj/
│   └── project.pbxproj
└── SimpleApp/
    ├── SimpleAppApp.swift     # @main entry point
    └── ContentView.swift      # UI
```

## Running Locally
Open `SimpleApp.xcodeproj` in Xcode and press **⌘R**.

## CI / GitHub Actions
The workflow in `.github/workflows/build.yml`:
- Triggers on push/PR to `main`
- Runs on `macos-latest`
- Builds with no code signing required (safe for CI)

```bash
xcodebuild build \
  -project SimpleApp.xcodeproj \
  -scheme SimpleApp \
  -configuration Debug \
  -destination "platform=macOS" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
```
