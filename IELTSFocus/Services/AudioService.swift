import Foundation
import AVFoundation
import AudioToolbox
import UIKit

final class AudioService: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = AudioService()
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var isAudioSessionConfigured = false
    
    // User preferences stored in UserDefaults
    var isVoiceEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "enableVoiceCoach") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "enableVoiceCoach") }
    }
    
    var isSoundEffectsEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "enableSoundEffects") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "enableSoundEffects") }
    }
    
    private override init() {
        super.init()
        speechSynthesizer.delegate = self
        configureAudioSession()
    }
    
    /// Configures AVAudioSession with .playback category so sounds play EVEN IN SILENT / MUTE MODE
    func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // .playback category overrides the physical mute / silent switch on iPhone 15 Pro Max
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            isAudioSessionConfigured = true
        } catch {
            print("AudioService: Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Spoken Tough Love Voice (AVSpeechSynthesizer)
    
    /// Speaks text aloud using iOS native Text-to-Speech
    func speak(_ text: String, force: Bool = false) {
        guard isVoiceEnabled || force else { return }
        
        // Re-ensure audio session is active and playback category is set
        configureAudioSession()
        
        // Stop any current speech to avoid overlap
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Use British English (en-GB) as primary for IELTS (British Council standard), with fallback to en-US
        if let britishVoice = AVSpeechSynthesisVoice(language: "en-GB") {
            utterance.voice = britishVoice
        } else if let usVoice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = usVoice
        }
        
        // Strict, firm coach cadence
        utterance.rate = 0.50
        utterance.pitchMultiplier = 0.95
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.05
        
        speechSynthesizer.speak(utterance)
    }
    
    // MARK: - Tough Love Preset Voice Lines
    
    func speakSessionStart(for sessionType: IELTSSessionType) {
        speak("Lock in bro! \(sessionType.durationMinutes) minutes of \(sessionType.rawValue). Band 8.0 requires absolute focus. No slacking.")
    }
    
    func speakSessionPause() {
        speak("Why are you pausing bro? Stay in the zone!")
    }
    
    func speakSessionResume() {
        speak("Back to work bro. Finish strong.")
    }
    
    func speakFrictionWarning() {
        speak("Bro, are you serious? You want to quit mid session? Band 8.0 will not achieve itself. Lock back in right now!")
    }
    
    func speakSessionComplete(for sessionType: IELTSSessionType) {
        speak("Good work bro! You completed your \(sessionType.rawValue) session. That is real discipline.")
    }
    
    func speakAbandonmentBust(secondsAway: Int) {
        speak("Busted! Bro, you abandoned your session for \(secondsAway) seconds! Get back to IELTS Focus right now!")
    }
    
    func speakGamePassStart(appName: String, minutes: Int) {
        speak("Take your \(minutes) minute break on \(appName) bro. But when the buzzer sounds, your phone goes face down.")
    }
    
    func speakGamePassExpired(appName: String) {
        speak("Bro! Your break on \(appName) is over! Put the phone down and get back to study right now!")
    }
    
    func speakReturnOnTime() {
        speak("Word kept bro. You came back on time. That's real discipline.")
    }
    
    func speakReturnLate(overtimeMinutes: Int) {
        speak("Slacker detected! You stayed out \(overtimeMinutes) extra minutes bro! Penalty recorded.")
    }
    
    func speakTestVoice() {
        speak("Yo bro! Strict Bro audio is working loud and clear on your iPhone! Put the games away and let's get Band 8.0!", force: true)
    }
    
    // MARK: - Native iOS Sound Effects (AudioToolbox System Sounds)
    
    /// Boxing bell / Start Chime (System Sound 1022)
    func playStartBell() {
        guard isSoundEffectsEnabled else { return }
        configureAudioSession()
        AudioServicesPlayAlertSound(SystemSoundID(1022))
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    /// Warning / Penalty Buzzer (System Sound 1005)
    func playBuzzer() {
        guard isSoundEffectsEnabled else { return }
        configureAudioSession()
        AudioServicesPlayAlertSound(SystemSoundID(1005))
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    /// Celebration / Victory Fanfare (System Sound 1304)
    func playVictory() {
        guard isSoundEffectsEnabled else { return }
        configureAudioSession()
        AudioServicesPlayAlertSound(SystemSoundID(1304))
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    /// Click / Button Feedback (System Sound 1104)
    func playClick() {
        guard isSoundEffectsEnabled else { return }
        AudioServicesPlaySystemSound(SystemSoundID(1104))
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    /// Critical Siren Alarm (System Sound 1008)
    func playSiren() {
        configureAudioSession()
        AudioServicesPlayAlertSound(SystemSoundID(1008))
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
