import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            StudyView()
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
    }
}

#Preview {
    ContentView()
}
