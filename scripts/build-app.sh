#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
if ! xcodebuild -version >/dev/null 2>&1; then
  echo "Full Xcode is required. Install Xcode or download the Copy-Cat artifact from GitHub Actions." >&2
  exit 1
fi
xcodebuild -project Maccy.xcodeproj -scheme Maccy -configuration Release \
  -derivedDataPath .build/xcode -destination 'generic/platform=macOS' \
  CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM= ENABLE_HARDENED_RUNTIME=NO \
  build
mkdir -p dist
ditto '.build/xcode/Build/Products/Release/Copy Cat.app' 'dist/Copy Cat.app'
codesign --verify --deep --strict 'dist/Copy Cat.app'
ditto -c -k --sequesterRsrc --keepParent 'dist/Copy Cat.app' 'dist/Copy-Cat.zip'
echo 'Built dist/Copy Cat.app and dist/Copy-Cat.zip'
