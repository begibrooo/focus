import SwiftUI
import SwiftData

@main
struct IELTSFocusApp: App {
    init() {
        // Initialize NotificationService and foreground delegate
        _ = NotificationService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Request notification permission on launch
                    _ = await NotificationService.shared.requestPermission()
                }
        }
        .modelContainer(for: StudySession.self)
    }
}
