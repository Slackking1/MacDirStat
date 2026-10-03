import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        // Set before the Dock tile appears so it never flashes the generic executable icon.
        if let icon = Self.appIcon() {
            NSApp.applicationIconImage = icon
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.activate()
    }

    // Same lookup as SPM's Bundle.module, which calls fatalError when the resource bundle
    // isn't beside the binary (e.g. the binary was copied elsewhere). A missing icon shouldn't crash.
    private static func appIcon() -> NSImage? {
        [Bundle.main.resourceURL, Bundle.main.bundleURL]
            .lazy
            .compactMap { $0.flatMap { Bundle(url: $0.appendingPathComponent("MacDirStat_MacDirStat.bundle")) } }
            .first?
            .image(forResource: "AppIcon")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

@main
struct MacDirStatApp: App {
    @NSApplicationDelegateAdaptor private var delegate: AppDelegate
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .frame(minWidth: 800, minHeight: 500)
        }
        .defaultSize(width: 1200, height: 800)
        .commands {
            OpenFolderCommands()
        }
    }
}

/// Menu commands read focused values from the key window, so ⌘O acts on the window in front.
struct OpenFolderCommands: Commands {
    @FocusedValue(\.openFolderAction) private var openFolder

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Open Folder...") {
                openFolder?()
            }
            .keyboardShortcut("o", modifiers: .command)
            .disabled(openFolder == nil)
        }
    }
}
