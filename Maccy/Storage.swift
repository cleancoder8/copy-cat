import Foundation
import AppKit
import Defaults
import SwiftData

@MainActor
class Storage {
  static let shared = Storage()

  var container: ModelContainer
  var context: ModelContext { container.mainContext }
  var size: String {
    guard let size = try? url.resourceValues(forKeys: [.fileSizeKey]).allValues.first?.value as? Int64, size > 1 else {
      return ""
    }

    return ByteCountFormatter().string(fromByteCount: size)
  }

  private let url = URL.applicationSupportDirectory.appending(path: "CopyCat/Storage.sqlite")

  init() {
    var config = ModelConfiguration(url: url)

    #if DEBUG
    if CommandLine.arguments.contains("enable-testing") {
      config = ModelConfiguration(isStoredInMemoryOnly: true)
    }
    #endif

    do {
      if !CommandLine.arguments.contains("enable-testing") {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                withIntermediateDirectories: true,
                                                attributes: [.posixPermissions: 0o700])
      }
      container = try ModelContainer(for: HistoryItem.self, configurations: config)
    } catch let error {
      fatalError("Cannot load database: \(error.localizedDescription).")
    }
    migratePrototypeIfNeeded()
  }

  private func migratePrototypeIfNeeded() {
    guard !CommandLine.arguments.contains("enable-testing"),
          !UserDefaults.standard.bool(forKey: "copyCatPrototypeImported") else { return }
    let legacyURL = url.deletingLastPathComponent().appendingPathComponent("history.json")
    guard FileManager.default.fileExists(atPath: legacyURL.path) else { return }
    do {
      try Self.importPrototype(Data(contentsOf: legacyURL), into: context)
      if let limit = UserDefaults.standard.object(forKey: "historyLimit") as? Int {
        Defaults[.size] = max(1, limit)
      }
      if let apps = UserDefaults.standard.string(forKey: "excludedApps") {
        Defaults[.ignoredApps] = apps.components(separatedBy: .newlines)
          .map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
      }
      UserDefaults.standard.set(true, forKey: "copyCatPrototypeImported")
    } catch {
      context.rollback()
      DispatchQueue.main.async {
        let alert = NSAlert()
        alert.messageText = "Previous Copy Cat history could not be imported"
        alert.informativeText = "Your original history.json is unchanged. \(error.localizedDescription)"
        alert.runModal()
      }
    }
  }

  /// Idempotent import; the JSON backup is never modified or deleted.
  static func importPrototype(_ data: Data, into context: ModelContext) throws {
    struct LegacyClip: Decodable {
      var text: String?
      var image: Data?
      var date: Date
      var pinned: Bool
    }
    let clips = try JSONDecoder().decode([LegacyClip].self, from: data)
    var existing = try context.fetch(FetchDescriptor<HistoryItem>())
    var pins = Set(existing.compactMap(\.pin))
    for clip in clips {
      let type: String
      let value: Data
      if let text = clip.text {
        type = NSPasteboard.PasteboardType.string.rawValue
        value = Data(text.utf8)
      } else if let image = clip.image {
        type = image.starts(with: [0x89, 0x50, 0x4e, 0x47])
          ? NSPasteboard.PasteboardType.png.rawValue : NSPasteboard.PasteboardType.tiff.rawValue
        value = image
      } else { continue }
      guard !existing.contains(where: { item in
        item.firstCopiedAt == clip.date && item.contents.contains { $0.type == type && $0.value == value }
      }) else { continue }
      let item = HistoryItem(contents: [HistoryItemContent(type: type, value: value)])
      context.insert(item)
      item.firstCopiedAt = clip.date
      item.lastCopiedAt = clip.date
      item.title = clip.text ?? ""
      if clip.pinned {
        // An empty shortcut still preserves a pin when letter slots are exhausted.
        item.pin = HistoryItem.supportedPins.subtracting(pins).sorted().first ?? ""
        pins.insert(item.pin!)
      }
      existing.append(item)
    }
    try context.save()
  }
}
