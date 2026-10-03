import AppKit
import Foundation

/// Detects Full Disk Access and opens the matching System Settings pane.
///
/// macOS has no API to request Full Disk Access, so the only option is to probe
/// a TCC-protected file and, if it can't be read, send the user to System Settings.
enum FullDiskAccess {
    /// Files that are only readable when the process has Full Disk Access.
    private static let probePaths = [
        "/Library/Application Support/com.apple.TCC/TCC.db",
        NSHomeDirectory() + "/Library/Safari/Bookmarks.plist",
    ]

    private static let settingsURL = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
    )!

    /// Returns true when access is granted, or when no probe file exists to test against.
    static var isGranted: Bool {
        let existing = probePaths.filter { FileManager.default.fileExists(atPath: $0) }
        guard !existing.isEmpty else { return true }

        return existing.contains { path in
            let fd = open(path, O_RDONLY)
            guard fd >= 0 else { return false }
            close(fd)
            return true
        }
    }

    static func openSystemSettings() {
        NSWorkspace.shared.open(settingsURL)
    }
}
