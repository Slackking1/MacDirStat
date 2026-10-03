import AppKit

enum FolderPicker {
    /// Shows an open panel for choosing a folder to scan. Returns nil if the user cancels.
    @MainActor
    static func chooseFolder() -> String? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select a folder to scan"
        panel.prompt = "Scan"

        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        return url.path(percentEncoded: false)
    }
}
