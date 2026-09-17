import SwiftUI

enum IELTSSessionType: String, CaseIterable, Identifiable {
    case listening = "Listening"
    case reading = "Reading"
    case writingTask1 = "Writing Task 1"
    case writingTask2 = "Writing Task 2"
    case speaking = "Speaking"
    
    var id: String { rawValue }
    
    var durationMinutes: Int {
        switch self {
        case .listening: return 30
        case .reading: return 60
        case .writingTask1: return 20
        case .writingTask2: return 40
        case .speaking: return 15
        }
    }
    
    var durationSeconds: Int {
        durationMinutes * 60
    }
    
    var icon: String {
        switch self {
        case .listening: return "headphones"
        case .reading: return "book.closed.fill"
        case .writingTask1: return "chart.bar.doc.horizontal"
        case .writingTask2: return "pencil.and.outline"
        case .speaking: return "waveform.and.mic"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .listening: return Color.blue
        case .reading: return Color.green
        case .writingTask1: return Color.orange
        case .writingTask2: return Color.purple
        case .speaking: return Color.pink
        }
    }
}
