//
//  VideoView.swift
//  dothething
//
//  Created by Nathan Chan on 11/13/22.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @EnvironmentObject var videoViewModel: VideoViewModel
    var clip: Clip

    var body: some View {
        ZStack {
            VideoPlayer(player: videoViewModel.player)
                .onAppear {
                    videoViewModel.syncToChosenClip(clip: clip)
                }
                .onDisappear {
                    videoViewModel.player.replaceCurrentItem(with: nil)
                }
            
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        videoViewModel.playPreviousClip()
                    }) {
                        // circular arrow button
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button(action: {
                        videoViewModel.playNextClip()
                    }) {
                        // circular arrow button
                        Image(systemName: "arrow.right")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.25))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
    }
}

//struct VideoView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoView(videoViewModel: VideoViewModel(clips: []), clip: Clip())
//    }
//}

class VideoViewModel: ObservableObject {
    @Published var player = AVPlayer()
    
    @Published var clips: [Clip]
    private var index: Int = 0
    
    init(clips: [Clip]) {
        print("Initializing VideoViewModel")
        self.clips = clips
        // play sound even when phone muted
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch {
            print("Failed to set audio session category.  Error: \(error)")
        }
        // restart video when it ends
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            self.player.seek(to: .zero)
            self.player.play()
        }
    }

    func syncToChosenClip(clip: Clip) {
        print("Entered VideoViewModel.syncToChosenClip")
        index = clips.firstIndex { $0.metadata.id == clip.metadata.id } ?? 0
        playThisVideo()
    }
    
    func playThisVideo() {
        print("Entered VideoViewModel.playThisVideo with index=\(index)")
        let id = clips[index].metadata.id
        print("video id=\(id)")
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let videoUrl = tempDirectory.appendingPathComponent(id)
        if fileManager.fileExists(atPath: videoUrl.path) {
            print("Video already downloaded")
            player = AVPlayer(url: videoUrl)
            player.play()
            return
        }
        Networker.downloadVideo(id: id) { data in
            do {
                try data.write(to: videoUrl)
                print("Successfully downloaded video")
                DispatchQueue.main.async {
                    self.player = AVPlayer(url: videoUrl)
                    self.player.play()
                }
            } catch {
                print("Error writing video to temporary directory")
            }
        }
    }
    
    func playNextClip() {
        if index < clips.count - 1 {
            index += 1
            player.replaceCurrentItem(with: nil)
            playThisVideo()
        }
    }
    
    func playPreviousClip() {
        if index > 0 {
            index -= 1
            player.replaceCurrentItem(with: nil)
            playThisVideo()
        }
    }
}
