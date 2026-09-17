import SwiftUI
import Observation

@Observable
final class TimerViewModel {
    enum TimerState {
        case idle
        case running
        case paused
        case completed
    }
    
    var selectedType: IELTSSessionType = .reading {
        didSet {
            if timerState == .idle {
                reset()
            }
        }
    }
    
    var remainingSeconds: Int = 3600
    var totalSeconds: Int = 3600
    var timerState: TimerState = .idle
    var showCompletionView: Bool = false
    
    private var timerTask: Task<Void, Never>?
    
    init() {
        reset()
    }
    
    var progress: Double {
        guard totalSeconds > 0 else { return 0.0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }
    
    var formattedTime: String {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func reset() {
        NotificationService.shared.cancelPendingNotifications()
        totalSeconds = selectedType.durationSeconds
        remainingSeconds = totalSeconds
        timerState = .idle
        timerTask?.cancel()
        timerTask = nil
    }
    
    func start() {
        guard timerState == .idle || timerState == .paused else { return }
        timerState = .running
        
        // Schedule notification for background completion alert
        NotificationService.shared.scheduleSessionCompleteNotification(
            for: selectedType,
            in: remainingSeconds
        )
        
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while !Task.isCancelled && remainingSeconds > 0 && timerState == .running {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled || timerState != .running { break }
                
                remainingSeconds -= 1
                
                if remainingSeconds <= 0 {
                    complete()
                    break
                }
            }
        }
    }
    
    func pause() {
        guard timerState == .running else { return }
        timerState = .paused
        timerTask?.cancel()
        
        // Cancel notification while paused so it doesn't fire prematurely
        NotificationService.shared.cancelPendingNotifications()
    }
    
    func resume() {
        start()
    }
    
    func cancel() {
        reset()
    }
    
    private func complete() {
        timerTask?.cancel()
        NotificationService.shared.cancelPendingNotifications()
        timerState = .completed
        showCompletionView = true
    }
    
    func dismissCompletion() {
        showCompletionView = false
        reset()
    }
}
