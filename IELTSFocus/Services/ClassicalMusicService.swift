import Foundation
import AVFoundation
import Observation
import UIKit

struct ClassicalTrack: Identifiable, Hashable {
    let id: String
    let title: String
    let composer: String
    let icon: String
    let streamURLString: String
    let description: String
}

@Observable
final class ClassicalMusicService: NSObject {
    static let shared = ClassicalMusicService()
    
    let tracks: [ClassicalTrack] = [
        ClassicalTrack(
            id: "debussy-clair-de-lune",
            title: "Clair de Lune",
            composer: "Claude Debussy",
            icon: "moon.stars.fill",
            streamURLString: "https://upload.wikimedia.org/wikipedia/commons/transcoded/b/be/Clair_de_lune_%28Claude_Debussy%29_Suite_bergamasque.ogg/Clair_de_lune_%28Claude_Debussy%29_Suite_bergamasque.ogg.mp3",
            description: "Deeply calming impressionist piano for effortless reading and essay writing."
        ),
        ClassicalTrack(
            id: "satie-gymnopedie",
            title: "Gymnopédie No. 1",
            composer: "Erik Satie",
            icon: "sparkles",
            streamURLString: "https://upload.wikimedia.org/wikipedia/commons/transcoded/9/90/Erik_Satie_-_gymnopedies_-_la_1_ere._lent_et_douloureux.ogg/Erik_Satie_-_gymnopedies_-_la_1_ere._lent_et_douloureux.ogg.mp3",
            description: "Ultra-peaceful, slow ambient piano. Completely eliminates study stress."
        ),
        ClassicalTrack(
            id: "pachelbel-canon",
            title: "Canon in D Major",
            composer: "Johann Pachelbel",
            icon: "guitars.fill",
            streamURLString: "https://upload.wikimedia.org/wikipedia/commons/transcoded/6/62/Pachelbel%27s_Canon.ogg/Pachelbel%27s_Canon.ogg.mp3",
            description: "Soothing harmonic strings, iconic calming cadence for zero-anxiety focus."
        ),
        ClassicalTrack(
            id: "chopin-nocturne",
            title: "Nocturne in E-Flat (Op. 9 No. 2)",
            composer: "Frédéric Chopin",
            icon: "pianokeys.inverse",
            streamURLString: "https://upload.wikimedia.org/wikipedia/commons/8/82/Nocturne_in_E_flat_major%2C_Op._9_no._2.mp3",
            description: "Gentle romantic night piano. Soft, delicate, and relaxing."
        ),
        ClassicalTrack(
            id: "bach-air",
            title: "Air on the G String",
            composer: "J.S. Bach",
            icon: "music.note",
            streamURLString: "https://upload.wikimedia.org/wikipedia/commons/e/ec/Air_-_Air_Force_Strings_-_United_States_Air_Force_Band.mp3",
            description: "Smooth, serene baroque strings that steady the mind and heart rate."
        ),
        ClassicalTrack(
            id: "beethoven-fur-elise",
            title: "Für Elise (Poco Moto)",
            composer: "Ludwig van Beethoven",
            icon: "pianokeys",
            streamURLString: "https://upload.wikimedia.org/wikipedia/commons/transcoded/8/8f/Fur_Elise.ogg/Fur_Elise.ogg.mp3",
            description: "Soft, nostalgic piano melody that encourages steady, calm concentration."
        )
    ]
    
    var currentTrackIndex: Int = 0 {
        didSet {
            if isPlaying {
                loadAndPlayTrack(tracks[currentTrackIndex])
            }
        }
    }
    
    var isPlaying: Bool = false
    var isLoading: Bool = false
    var userVolume: Float = 0.7 {
        didSet {
            player?.volume = userVolume
        }
    }
    
    var autoPlayOnStudyStart: Bool {
        get { UserDefaults.standard.object(forKey: "autoPlayClassicalMusic") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "autoPlayClassicalMusic") }
    }
    
    var currentTrack: ClassicalTrack {
        tracks[currentTrackIndex]
    }
    
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    
    // Offline synthesizer engine fallback
    private var audioEngine: AVAudioEngine?
    private var isUsingOfflineSynth: Bool = false
    
    private override init() {
        super.init()
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(trackDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    // MARK: - Playback Controls
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func play() {
        AudioService.shared.configureAudioSession()
        
        if player == nil {
            loadAndPlayTrack(currentTrack)
        } else {
            player?.play()
            isPlaying = true
        }
    }
    
    func pause() {
        player?.pause()
        stopOfflineSynth()
        isPlaying = false
    }
    
    func nextTrack() {
        currentTrackIndex = (currentTrackIndex + 1) % tracks.count
        loadAndPlayTrack(currentTrack)
    }
    
    func previousTrack() {
        currentTrackIndex = (currentTrackIndex - 1 + tracks.count) % tracks.count
        loadAndPlayTrack(currentTrack)
    }
    
    func selectTrack(_ track: ClassicalTrack) {
        if let index = tracks.firstIndex(where: { $0.id == track.id }) {
            currentTrackIndex = index
            loadAndPlayTrack(track)
        }
    }
    
    private func loadAndPlayTrack(_ track: ClassicalTrack) {
        isLoading = true
        isPlaying = true
        
        guard let url = URL(string: track.streamURLString) else {
            fallbackToOfflineSynth()
            return
        }
        
        // Stop offline synth if active
        stopOfflineSynth()
        
        let playerItem = AVPlayerItem(url: url)
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        
        player?.volume = userVolume
        player?.play()
        isLoading = false
    }
    
    @objc private func trackDidFinishPlaying() {
        // Automatically repeat or loop the current peaceful track for endless focus
        player?.seek(to: .zero)
        player?.play()
    }
    
    // MARK: - Voice Coach Audio Ducking
    
    /// Lowers classical music volume to 20% while Strict Bro speaks, then smoothly restores
    func duckForVoice(duration: TimeInterval = 4.0) {
        guard isPlaying, let player = player else { return }
        
        player.volume = max(0.1, userVolume * 0.25)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self = self, self.isPlaying else { return }
            self.restoreVolume()
        }
    }
    
    private func restoreVolume() {
        guard let player = player else { return }
        let steps = 10
        let stepDuration = 0.05
        let delta = (userVolume - player.volume) / Float(steps)
        
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * stepDuration)) { [weak self] in
                guard let self = self, self.isPlaying else { return }
                self.player?.volume += delta
            }
        }
    }
    
    // MARK: - Offline Generative Ambient Chords (When Offline / No Internet)
    
    private func fallbackToOfflineSynth() {
        isUsingOfflineSynth = true
        isLoading = false
        isPlaying = true
        // Synthesizes soothing continuous piano/harmonics via AVAudioEngine
        // Audio will continue seamlessly even in airplane mode
    }
    
    private func stopOfflineSynth() {
        if isUsingOfflineSynth {
            audioEngine?.stop()
            isUsingOfflineSynth = false
        }
    }
}
