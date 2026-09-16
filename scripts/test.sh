#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
python3 - "$TMP_DIR/Tests.swift" <<'PY'
import sys
source = open('Tests/CopyCatTests/HistoryTests.swift').read()
source = source.replace('import XCTest', '').replace('@testable import CopyCat', '').replace(': XCTestCase', '').replace('override func', 'func')
source += '''
func XCTAssertTrue(_ value: Bool) { precondition(value) }
func XCTAssertEqual<T: Equatable>(_ lhs: T, _ rhs: T) { precondition(lhs == rhs, "Values differ") }
@main struct Runner {
    static func main() {
        let tests = HistoryTests()
        let cases = [tests.testDuplicateKeepsIdentityAndPinAcrossReload,
                     tests.testClearKeepsPinsAndSearchMatchesSource,
                     tests.testMonitoringSkipsConfidentialAndPausedCopies,
                     tests.testCopyDoesNotRecaptureAndImagePersists]
        for test in cases { tests.setUp(); test(); tests.tearDown() }
        print("All 4 history checks passed.")
    }
}
'''
open(sys.argv[1], 'w').write(source)
PY
swiftc Sources/CopyCat/History.swift "$TMP_DIR/Tests.swift" -o "$TMP_DIR/HistoryTests"
"$TMP_DIR/HistoryTests"
