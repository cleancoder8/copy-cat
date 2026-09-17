#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
# Pass -only-testing:MaccyTests to run the unit suite without UI automation.
xcodebuild -project Maccy.xcodeproj -scheme Maccy -configuration Debug \
  -derivedDataPath .build/tests -destination 'platform=macOS' \
  -parallel-testing-enabled NO \
  CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM= \
  test "$@"
