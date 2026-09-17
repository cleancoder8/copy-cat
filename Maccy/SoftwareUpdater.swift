import Sparkle
import AppKit

@Observable
class SoftwareUpdater {
  var isConfigured: Bool { Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String != nil }

  var automaticallyChecksForUpdates = false {
    didSet {
      updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates
    }
  }

  private var updater: SPUUpdater
  private var automaticallyChecksForUpdatesObservation: NSKeyValueObservation?

  private let updaterController = SPUStandardUpdaterController(
    startingUpdater: Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String != nil,
    updaterDelegate: nil,
    userDriverDelegate: nil
  )

  init() {
    updater = updaterController.updater
    automaticallyChecksForUpdatesObservation = updater.observe(
      \.automaticallyChecksForUpdates,
      options: [.initial, .new, .old]
    ) { [unowned self] updater, change in
      guard change.newValue != change.oldValue else {
        return
      }

      self.automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
    }
  }

  func checkForUpdates() {
    if isConfigured {
      updater.checkForUpdates()
    } else {
      NSWorkspace.shared.open(URL(string: "https://github.com/cleancoder8/copy-cat/releases")!)
    }
  }
}
