import AppKit
import SwiftUI
import Carbon

@main
struct CopyCatApp {
    static func main() {
        let application = NSApplication.shared
        let delegate = AppDelegate()
        application.delegate = delegate
        withExtendedLifetime(delegate) { application.run() }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    let history = History()
    private var status: NSStatusItem!
    private let popover = NSPopover()
    private var hotKey: EventHotKeyRef?
    private var handler: EventHandlerRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        status = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        status.button?.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "Copy Cat clipboard history")
        status.button?.target = self
        status.button?.action = #selector(toggle)
        status.button?.toolTip = "Copy Cat · ⌘⇧V"
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 440, height: 580)
        popover.contentViewController = NSHostingController(rootView: HistoryView(history: history, onCopy: { [weak self] clip in
            self?.history.copy(clip)
            self?.popover.performClose(nil)
        }))
        var event = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, context in
            guard let context else { return noErr }
            let app = Unmanaged<AppDelegate>.fromOpaque(context).takeUnretainedValue()
            app.toggle()
            return noErr
        }, 1, &event, Unmanaged.passUnretained(self).toOpaque(), &handler)
        let result = RegisterEventHotKey(UInt32(kVK_ANSI_V), UInt32(cmdKey | shiftKey), EventHotKeyID(signature: 0x43434154, id: 1), GetApplicationEventTarget(), 0, &hotKey)
        if result != noErr { history.error = "⌘⇧V is unavailable. Open Copy Cat from the menu bar." }
        DispatchQueue.main.async { self.toggle() }
    }
    @objc func toggle() {
        if popover.isShown { popover.performClose(nil); return }
        guard let button = status.button else { return }
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }
    func applicationWillTerminate(_ notification: Notification) {
        if let hotKey { UnregisterEventHotKey(hotKey) }
        if let handler { RemoveEventHandler(handler) }
    }
}
