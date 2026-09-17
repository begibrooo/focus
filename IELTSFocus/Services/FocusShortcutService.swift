import UIKit

final class FocusShortcutService {
    /// Launches the Shortcuts app to execute a specific shortcut by name
    @discardableResult
    static func runShortcut(named name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty,
              let encodedName = trimmedName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
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
    
    /// Opens the Apple Shortcuts app directly to create a new shortcut
    @discardableResult
    static func openCreateShortcut() -> Bool {
        if let url = URL(string: "shortcuts://create-shortcut"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return true
        } else if let fallbackUrl = URL(string: "shortcuts://"), UIApplication.shared.canOpenURL(fallbackUrl) {
            UIApplication.shared.open(fallbackUrl)
            return true
        }
        return false
    }
    
    /// Opens iOS Focus / Do Not Disturb Settings directly
    @discardableResult
    static func openFocusSettings() -> Bool {
        let candidateURLs = [
            "App-Prefs:root=FOCUS",
            "App-Prefs:root=DO_NOT_DISTURB",
            "prefs:root=DO_NOT_DISTURB",
            UIApplication.openSettingsURLString
        ]
        
        for urlString in candidateURLs {
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return true
            }
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
