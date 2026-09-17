import UIKit

final class FocusShortcutService {
    /// Launches the Shortcuts app to execute a specific shortcut by name
    @discardableResult
    static func runShortcut(named name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let encodedName = trimmedName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "shortcuts://run-shortcut?name=\(encodedName)") else {
            return false
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return true
        } else if let fallbackUrl = URL(string: "shortcuts://"), UIApplication.shared.canOpenURL(fallbackUrl) {
            UIApplication.shared.open(fallbackUrl)
            return true
        }
        return false
    }
    
    /// Opens the Shortcuts app root
    static func openShortcutsApp() {
        if let url = URL(string: "shortcuts://"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
