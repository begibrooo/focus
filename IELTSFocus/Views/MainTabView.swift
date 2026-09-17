import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
                .tag(0)
            
            FocusHubView()
                .tabItem {
                    Label("Focus Shield", systemImage: "shield.lefthalf.filled")
                }
                .tag(1)
            
            StatsView()
                .tabItem {
                    Label("Log & Streaks", systemImage: "chart.bar.xaxis")
                }
                .tag(2)
        }
        .tint(Theme.primary)
        .task {
            // Request local notification permissions on app launch
            _ = await NotificationManager.shared.requestPermission()
        }
    }
}
