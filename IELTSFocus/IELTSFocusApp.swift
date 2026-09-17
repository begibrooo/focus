import SwiftUI
import SwiftData

@main
struct IELTSFocusApp: App {
    init() {
        // Initialize NotificationService and foreground delegate
        _ = NotificationService.shared
        // Initialize AudioService and configure .playback category (plays in Silent Mode)
        _ = AudioService.shared
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
