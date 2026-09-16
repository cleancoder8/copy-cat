import XCTest
import AppKit
@testable import CopyCat

final class HistoryTests: XCTestCase {
    private var directory: URL!
    private var board: NSPasteboard!
    override func setUp() {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        board = NSPasteboard.withUniqueName()
    }
    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        board.releaseGlobally()
    }
    private func makeHistory() -> History {
        History(file: directory.appendingPathComponent("history.json"), pasteboard: board, monitoring: false)
    }
    func testDuplicateKeepsIdentityAndPinAcrossReload() {
        let history = makeHistory()
        let clip = Clip(text: "Hello", source: "Test")
        history.add(clip)
        history.pin(clip)
        history.add(Clip(text: "Hello", source: "Another app"))
        XCTAssertEqual(history.clips.count, 1)
        XCTAssertEqual(history.clips[0].id, clip.id)
        XCTAssertTrue(history.clips[0].pinned)
        XCTAssertEqual(makeHistory().clips, history.clips)
    }
    func testClearKeepsPinsAndSearchMatchesSource() {
        let history = makeHistory()
        let clip = Clip(text: "Keep", source: "Safari")
        history.add(clip)
        history.pin(clip)
        history.add(Clip(text: "Remove", source: "Notes"))
        XCTAssertEqual(history.filtered("sAFaRi").count, 1)
        history.clear()
        XCTAssertEqual(history.clips.map(\.text), ["Keep"])
    }
    func testMonitoringSkipsConfidentialAndPausedCopies() {
        let history = makeHistory()
        board.setString("secret", forType: .string)
        board.setString("1", forType: NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType"))
        history.poll()
        XCTAssertTrue(history.clips.isEmpty)
        board.clearContents()
        board.setString("ordinary", forType: .string)
        history.poll()
        XCTAssertEqual(history.clips.first?.text, "ordinary")
        history.paused = true
        board.clearContents()
        board.setString("paused", forType: .string)
        history.poll()
        XCTAssertEqual(history.clips.count, 1)
    }
    func testCopyDoesNotRecaptureAndImagePersists() {
        let history = makeHistory()
        let clip = Clip(text: "Copy me", source: "Test")
        history.copy(clip)
        history.poll()
        XCTAssertEqual(board.string(forType: .string), "Copy me")
        XCTAssertTrue(history.clips.isEmpty)
        let image = Clip(image: Data([1, 2, 3]), source: "Test")
        history.add(image)
        XCTAssertEqual(makeHistory().clips.first?.image, image.image)
    }
}
