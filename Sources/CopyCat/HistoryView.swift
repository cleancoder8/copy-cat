import SwiftUI
import AppKit

private typealias ViewState<Value> = SwiftUI.State<Value>

struct HistoryView: View {
    @ObservedObject var history: History
    var onCopy: (Clip) -> Void
    @ViewState<String> private var query = ""
    @ViewState<Bool> private var pinnedOnly = false
    @ViewState<UUID?> private var selection: UUID?
    @ViewState<Bool> private var settings = false
    @ViewState<Bool> private var confirmClear = false
    @FocusState private var searchFocused: Bool
    private var results: [Clip] { history.filtered(query, pinnedOnly: pinnedOnly) }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "square.on.square.fill").font(.title2).foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Copy Cat").font(.system(size: 17, weight: .semibold))
                    Text(history.paused ? "Clipboard capture paused" : "A little memory for your Mac").font(.system(size: 11)).foregroundStyle(.secondary)
                }
                Spacer()
                Text("⌘⇧V").font(.system(size: 12, design: .monospaced)).foregroundStyle(.secondary).padding(6).background(.quaternary, in: RoundedRectangle(cornerRadius: 5))
            }.padding(18)
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search your clipboard…", text: $query).textFieldStyle(.plain).focused($searchFocused)
                    .onSubmit { copySelected() }
                if !query.isEmpty {
                    Button { query = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }.buttonStyle(.plain)
                }
            }.padding(11).background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 9)).padding(.horizontal, 16)
            HStack(spacing: 6) {
                filterButton("All history", active: !pinnedOnly) { pinnedOnly = false }
                filterButton("Pinned", active: pinnedOnly) { pinnedOnly = true }
                Spacer()
                Text("\(results.count) items").font(.system(size: 11)).foregroundStyle(.tertiary)
            }.padding(.horizontal, 16).padding(.vertical, 12)
            Divider()
            if results.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: query.isEmpty ? "clipboard" : "magnifyingglass").font(.system(size: 34, weight: .light)).foregroundStyle(.tertiary)
                    Text(query.isEmpty ? (pinnedOnly ? "Keep the good stuff" : "Your next copy starts here") : "No matching clips").font(.headline)
                    Text(query.isEmpty ? (pinnedOnly ? "Pin a clip to keep it close, even when history is cleared." : "Copy text or an image in any app.\nIt will be waiting for you here.") : "Try another word or app name.")
                        .font(.system(size: 12)).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 3) {
                            ForEach(Array(results.enumerated()), id: \.element.id) { index, clip in
                                row(clip, index: index).id(clip.id)
                            }
                        }.padding(8)
                    }.onChange(of: selection) { _, id in if let id { proxy.scrollTo(id) } }
                }
            }
            if let error = history.error {
                Text(error).font(.caption).foregroundStyle(.red).padding(8)
            }
            Divider()
            HStack {
                Circle().fill(history.paused ? Color.orange : Color.green).frame(width: 6, height: 6)
                Text(history.paused ? "Paused" : "Only on this Mac").font(.system(size: 11)).foregroundStyle(.secondary)
                Spacer()
                Text("↑↓ navigate  ↵ copy").font(.system(size: 10)).foregroundStyle(.tertiary)
                Menu {
                    Button(history.paused ? "Resume capture" : "Pause capture") { history.paused.toggle() }
                    Button("Settings…") { settings = true }
                    Button("Clear unpinned history…") { confirmClear = true }
                    Divider()
                    Button("Quit Copy Cat") { NSApp.terminate(nil) }
                } label: { Image(systemName: "gearshape").font(.system(size: 13)) }.menuStyle(.borderlessButton).fixedSize().padding(.leading, 8)
            }.padding(14)
        }
        .frame(width: 440, height: 580)
        .background(.regularMaterial)
        .onAppear { searchFocused = true; selection = results.first?.id }
        .onChange(of: query) { _, _ in selection = results.first?.id }
        .onChange(of: pinnedOnly) { _, _ in selection = results.first?.id }
        .onChange(of: results.map(\.id)) { _, ids in if !ids.contains(selection ?? UUID()) { selection = ids.first } }
        .onMoveCommand { direction in
            let index = results.firstIndex { $0.id == selection } ?? 0
            if direction == .down { select(index + 1) }
            if direction == .up { select(index - 1) }
        }
        .onExitCommand { NSApp.keyWindow?.close() }
        .sheet(isPresented: $settings) { settingsView }
        .alert("Clear clipboard history?", isPresented: $confirmClear) {
            Button("Cancel", role: .cancel) {}
            Button("Clear history", role: .destructive) { history.clear() }
        } message: { Text("Pinned clips will be kept. This does not clear your current system clipboard.") }
    }
    private func filterButton(_ title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) { Text(title).font(.system(size: 11, weight: .medium)).padding(.horizontal, 10).padding(.vertical, 5).background(active ? Color.primary.opacity(0.08) : Color.clear, in: Capsule()) }.buttonStyle(.plain)
    }
    private func row(_ clip: Clip, index: Int) -> some View {
        HStack(spacing: 11) {
            Button { onCopy(clip) } label: {
                HStack(spacing: 11) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.045))
                        if let data = clip.image, let image = NSImage(data: data) {
                            Image(nsImage: image).resizable().scaledToFit().padding(3)
                        } else { Image(systemName: clip.symbol).foregroundStyle(clip.symbol == "link" ? .blue : .secondary) }
                    }.frame(width: 36, height: 36)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(clip.title.replacingOccurrences(of: "\n", with: " ")).font(.system(size: 12, weight: .medium)).lineLimit(2).multilineTextAlignment(.leading)
                        HStack(spacing: 4) {
                            Text(clip.source)
                            Text("·")
                            Text(clip.date, style: .relative)
                        }.font(.system(size: 10)).foregroundStyle(.secondary).lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }.contentShape(Rectangle())
            }.buttonStyle(.plain)
            Button { history.pin(clip) } label: {
                Image(systemName: clip.pinned ? "pin.fill" : "pin").font(.system(size: 11)).foregroundStyle(clip.pinned ? Color.orange : Color.secondary.opacity(0.5))
            }.buttonStyle(.plain).help(clip.pinned ? "Unpin" : "Pin")
        }
        .padding(10)
        .background(selection == clip.id ? Color.accentColor.opacity(0.12) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
        .contextMenu {
            Button("Copy") { onCopy(clip) }
            Button(clip.pinned ? "Unpin" : "Pin") { history.pin(clip) }
            Button("Delete", role: .destructive) { history.remove(clip) }
        }
        .help(clip.text.map { String($0.prefix(1000)) } ?? "Image")
    }
    private func select(_ index: Int) {
        guard !results.isEmpty else { return }
        selection = results[min(max(index, 0), results.count - 1)].id
    }
    private func copySelected() {
        if let clip = results.first(where: { $0.id == selection }) ?? results.first { onCopy(clip) }
    }
    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Settings").font(.title2.bold())
            Picker("History limit", selection: $history.limit) {
                ForEach([50, 100, 200, 500, 1000], id: \.self) { Text("\($0) clips").tag($0) }
            }
            Text("Pinned clips are kept beyond this limit.").font(.caption).foregroundStyle(.secondary)
            Text("Ignore these apps").font(.headline)
            Text("Enter one bundle identifier per line, e.g. com.apple.keychainaccess.").font(.caption).foregroundStyle(.secondary)
            TextEditor(text: $history.excludedApps).font(.system(.caption, design: .monospaced)).frame(height: 85).border(.quaternary)
            Text("History is stored locally, without encryption. Clipboard items marked confidential or temporary are skipped. Text formatting is not retained.").font(.caption).foregroundStyle(.secondary)
            HStack { Spacer(); Button("Done") { settings = false }.keyboardShortcut(.defaultAction) }
        }.padding(24).frame(width: 390)
    }
}
