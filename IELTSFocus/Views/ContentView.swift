import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var timerViewModel = TimerViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                StudyView(viewModel: timerViewModel)
                    .tabItem {
                        Label("Study", systemImage: "timer")
                    }
                    .tag(0)
                
                LogView()
                    .tabItem {
                        Label("Log", systemImage: "chart.bar.xaxis")
                    }
                    .tag(1)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            
            // Native iPhone 15 Pro Max Dynamic Island Live Activity Capsule
            DynamicIslandView(viewModel: timerViewModel)
        }
    }
}

#Preview {
    ContentView()
}
