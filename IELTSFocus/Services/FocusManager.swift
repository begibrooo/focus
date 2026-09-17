import UIKit

final class FocusManager {
    static let shared = FocusManager()
    
    private init() {}
    
    /// Launches the Apple Shortcuts app to run a user's 'Study Focus' shortcut.
    /// In iOS, users can create a simple 1-step shortcut named "Study Focus"
    /// that turns on Do Not Disturb or a custom Focus mode.
    @discardableResult
    func triggerFocusModeShortcut(shortcutName: String = "Study Focus") -> Bool {
        guard let encodedName = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "shortcuts://run-shortcut?name=\(encodedName)") else {
            return false
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        } else if let fallback = URL(string: "shortcuts://") {
            UIApplication.shared.open(fallback, options: [:], completionHandler: nil)
            return true
        }
        return false
    }
    
    /// Jumps directly to Screen Time in the iOS Settings app so the user can
    /// adjust App Limits on games/social media.
    @discardableResult
    func openScreenTimeSettings() -> Bool {
        // App-Prefs deep links work on sideloaded apps signed for personal use
        if let prefsURL = URL(string: "App-Prefs:root=SCREEN_TIME"),
           UIApplication.shared.canOpenURL(prefsURL) {
            UIApplication.shared.open(prefsURL, options: [:], completionHandler: nil)
            return true
        }
        
        // Universal fallback to app / system settings
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            return true
        }
        
        return false
    }
}
