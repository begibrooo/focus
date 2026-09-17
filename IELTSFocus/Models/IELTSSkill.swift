import SwiftUI

enum IELTSSkill: String, CaseIterable, Identifiable, Codable {
    case listening = "Listening"
    case reading = "Reading"
    case writingTask1 = "Writing Task 1"
    case writingTask2 = "Writing Task 2"
    case speaking = "Speaking"
    case custom = "Custom Practice"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .writingTask1: return "Writing T1 (20m)"
        case .writingTask2: return "Writing T2 (40m)"
        case .listening: return "Listening (40m)"
        case .reading: return "Reading (60m)"
        case .speaking: return "Speaking (15m)"
        case .custom: return "Quick Drill"
        }
    }
    
    var defaultDurationMinutes: Int {
        switch self {
        case .listening: return 40
        case .reading: return 60
        case .writingTask1: return 20
        case .writingTask2: return 40
        case .speaking: return 15
        case .custom: return 25
        }
    }
    
    var defaultDurationSeconds: Int {
        defaultDurationMinutes * 60
    }
    
    var systemImage: String {
        switch self {
        case .listening: return "headphones"
        case .reading: return "book.closed.fill"
        case .writingTask1: return "chart.bar.doc.horizontal"
        case .writingTask2: return "pencil.and.outline"
        case .speaking: return "waveform.and.mic"
        case .custom: return "timer"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .listening: return Theme.listening
        case .reading: return Theme.reading
        case .writingTask1: return Theme.writing1
        case .writingTask2: return Theme.writing2
        case .speaking: return Theme.speaking
        case .custom: return Theme.general
        }
    }
    
    var band8Tips: [String] {
        switch self {
        case .listening:
            return [
                "Scan questions during the 30s preview to predict word types (noun, date, number).",
                "Beware of distractors: speakers often correct themselves mid-sentence.",
                "Singular vs. plural accuracy is critical for Band 8.0."
            ]
        case .reading:
            return [
                "Do not read the full text first; skim headings and scan keywords directly.",
                "True/False/Not Given: 'Not Given' means the writer never confirmed nor denied.",
                "Allocate strictly 20 minutes per passage to finish all 40 questions."
            ]
        case .writingTask1:
            return [
                "Always include an Overview paragraph highlighting the most noticeable trends.",
                "Never share personal opinions in Task 1—report strictly on presented data.",
                "Use precise vocabulary for changes: skyrocketed, plateaued, fluctuated."
            ]
        case .writingTask2:
            return [
                "Address all parts of the prompt with well-developed supporting points.",
                "Vary complex sentences and use natural academic collocations.",
                "Leave 3-4 minutes to check for punctuation and subject-verb agreement."
            ]
        case .speaking:
            return [
                "Extend answers naturally using cause, effect, and personal examples.",
                "Idiomatic language: use natural collocations rather than obscure archaic idioms.",
                "Fluency and coherence are weighed higher than trying to speak unnaturally fast."
            ]
        case .custom:
            return [
                "Consistent deliberate practice beats sporadic marathon sessions.",
                "Target IELTS 8.0 requires disciplined, uninterrupted focus."
            ]
        }
    }
}
