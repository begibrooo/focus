import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized: Bool = false
    private let notificationIdPrefix = "IELTSFocusTimer"
    
    private init() {
        checkAuthorization()
    }
    
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            self.isAuthorized = granted
            return granted
        } catch {
            print("Failed to request notification permission: \(error.localizedDescription)")
            return false
        }
    }
    
    func scheduleSessionEndNotification(skill: IELTSSkill, durationSeconds: Int) {
        cancelActiveNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "\(skill.rawValue) Session Complete! 🎯"
        content.body = "Great focus! You've successfully logged \(skill.defaultDurationMinutes) minutes toward your IELTS 8.0 target."
        content.sound = .default
        
        // Trigger after durationSeconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(max(durationSeconds, 1)), repeats: false)
        let request = UNNotificationRequest(identifier: notificationIdPrefix, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelActiveNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdPrefix])
    }
}
