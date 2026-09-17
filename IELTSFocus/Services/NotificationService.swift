import Foundation
import UserNotifications

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    private let sessionNotificationID = "IELTSFocusSessionComplete"
    private let dailyReminderNotificationID = "IELTSDailyStudyReminder"
    private let distractionBreakNotificationID = "IELTSDistractionBreakOver"
    private let abandonmentWarningNotificationID = "IELTSAbandonedSessionWarning"
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// Requests notification permission from the user on launch
    @discardableResult
    func requestPermission() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            
            if settings.authorizationStatus == .notDetermined {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            }
            return settings.authorizationStatus == .authorized
        } catch {
            print("Notification permission error: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Schedules a local notification when the timer expires
    func scheduleSessionCompleteNotification(for sessionType: IELTSSessionType, in seconds: Int) {
        cancelPendingNotifications()
        guard seconds > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Good work bro! Session finished. 🎯"
        content.body = "You crushed \(sessionType.durationMinutes) min of \(sessionType.rawValue). That's real discipline. Keep this up for Band 8.0."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: sessionNotificationID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelPendingNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [sessionNotificationID])
        cancelAbandonmentWarning()
    }
    
    // MARK: - Abandonment Warning (When User Leaves App During Session)
    
    /// Called when the app is backgrounded while a session is actively running
    func scheduleAbandonmentWarning() {
        cancelAbandonmentWarning()
        
        let content = UNMutableNotificationContent()
        content.title = "🚨 BRO, WHERE ARE YOU GOING?!"
        content.body = "Your IELTS study timer is running! Get back in the app right now or your streak takes a hit."
        content.sound = .defaultCritical
        
        // Fires 12 seconds after leaving the app
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 12, repeats: false)
        let request = UNNotificationRequest(identifier: abandonmentWarningNotificationID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error setting abandonment warning: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelAbandonmentWarning() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [abandonmentWarningNotificationID])
    }
    
    // MARK: - Daily Study Reminder
    
    func scheduleDailyReminder(hour: Int, minute: Int) {
        cancelDailyReminder()
        
        let content = UNMutableNotificationContent()
        content.title = "Yo bro, wake up and study! 🥊"
        content.body = "Band 8.0 won't achieve itself while you scroll. Put the games away and lock in for a session right now."
        content.sound = .defaultCritical
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderNotificationID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error setting daily reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyReminderNotificationID])
    }
    
    // MARK: - Game Allowance Alert
    
    func scheduleDistractionBreakAlert(afterMinutes minutes: Int) {
        cancelDistractionBreakAlert()
        guard minutes > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🚨 BRO! BREAK IS OVER. LOCK IN."
        content.body = "Your \(minutes) minutes are up. Close TikTok, close the game. Don't trade your IELTS 8.0 dream for cheap dopamine."
        content.sound = .defaultCritical
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutes * 60), repeats: false)
        let request = UNNotificationRequest(identifier: distractionBreakNotificationID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling break alert: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelDistractionBreakAlert() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [distractionBreakNotificationID])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
