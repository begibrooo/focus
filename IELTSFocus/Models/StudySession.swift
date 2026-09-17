import Foundation
import SwiftData

@Model
final class StudySession {
    var id: UUID = UUID()
    var date: Date = Date()
    var sessionTypeRaw: String = IELTSSessionType.reading.rawValue
    var durationMinutes: Int = 60
    
    var sessionType: IELTSSessionType {
        get { IELTSSessionType(rawValue: sessionTypeRaw) ?? .reading }
        set { sessionTypeRaw = newValue.rawValue }
    }
    
    init(date: Date = Date(), sessionType: IELTSSessionType, durationMinutes: Int) {
        self.id = UUID()
        self.date = date
        self.sessionTypeRaw = sessionType.rawValue
        self.durationMinutes = durationMinutes
    }
}
