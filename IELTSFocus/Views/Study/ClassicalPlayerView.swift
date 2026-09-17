import SwiftUI

struct ClassicalPlayerView: View {
    @State private var musicService = ClassicalMusicService.shared
    @State private var showTrackPicker: Bool = false
    @State private var isWaveAnimated: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Music Icon & Track Info
                Button {
                    showTrackPicker = true
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 42, height: 42)
                            
                            Image(systemName: musicService.currentTrack.icon)
                                .font(.system(size: 18))
                                .foregroundStyle(Color.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(musicService.currentTrack.title)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                
                                if musicService.isPlaying {
                                    // Animated Mini Waveform
                                    equalizerBars
                                }
                            }
                            
                            Text(musicService.currentTrack.composer)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                
                // Controls: Previous / Play-Pause / Next
                HStack(spacing: 8) {
                    Button {
                        musicService.previousTrack()
                        AudioService.shared.playClick()
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                    }
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            musicService.togglePlayPause()
                        }
                        AudioService.shared.playClick()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 38, height: 38)
                            
                            Image(systemName: musicService.isPlaying ? "pause.fill" : "play.fill")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)
                                .offset(x: musicService.isPlaying ? 0 : 1)
                        }
                    }
                    
                    Button {
                        musicService.nextTrack()
                        AudioService.shared.playClick()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .sheet(isPresented: $showTrackPicker) {
            trackPickerSheet
        }
        .onAppear {
            isWaveAnimated = true
        }
    }
    
    // MARK: - Mini Equalizer Animation
    private var equalizerBars: some View {
        HStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.blue)
                    .frame(width: 2, height: isWaveAnimated ? [12, 6, 14, 8][index] : [4, 10, 5, 12][index])
                    .animation(
                        .easeInOut(duration: [0.45, 0.6, 0.5, 0.4][index])
                            .repeatForever(autoreverses: true),
                        value: isWaveAnimated
                    )
            }
        }
    }
    
    // MARK: - Track Picker Sheet
    private var trackPickerSheet: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Auto-Play with Study Timer", isOn: $musicService.autoPlayOnStudyStart)
                } header: {
                    Text("Focus Preferences")
                } footer: {
                    Text("Classical music will automatically play softly in the background when you lock in.")
                }
                
                Section {
                    ForEach(musicService.tracks) { track in
                        let isSelected = musicService.currentTrack.id == track.id
                        
                        Button {
                            musicService.selectTrack(track)
                            AudioService.shared.playClick()
                            showTrackPicker = false
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(isSelected ? Color.blue.opacity(0.15) : Color.primary.opacity(0.06))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: track.icon)
                                        .foregroundStyle(isSelected ? Color.blue : Color.secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(track.title)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                        
                                        if isSelected {
                                            Image(systemName: "checkmark")
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                    
                                    Text("\(track.composer) • \(track.description)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("Classical Study Tracks (Royalty-Free)")
                } footer: {
                    Text("Selected specifically for IELTS analytical reading, essay writing flow, and alpha brainwaves.")
                }
            }
            .navigationTitle("Classical Focus Audio 🎧")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showTrackPicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    ClassicalPlayerView()
        .padding()
}
