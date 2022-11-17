//
//  VideoView.swift
//  dothething
//
//  Created by Nathan Chan on 11/13/22.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @ObservedObject private(set) var videoViewModel: VideoViewModel

    var body: some View {
        ZStack {
            VideoPlayer(player: videoViewModel.player)
                .onAppear {
                    videoViewModel.handleOnAppear()
                    videoViewModel.player.play()
                }
                .onDisappear {
                    videoViewModel.player.pause()
                    videoViewModel.player.seek(to: .zero)
                }
        }
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView(videoViewModel: VideoView.VideoViewModel(videoId: "dothethingtest0.mov"))
    }
}

extension VideoView {
    class VideoViewModel: ObservableObject {
        @Published var player = AVPlayer()
        
        private var videoId: String
        
        init(videoId: String) {
            print("Initializing VideoViewModel: \(videoId)")
            self.videoId = videoId
        }
        
        func handleOnAppear() {
            print("Entered VideoViewModel.handleOnAppear")
            let fileManager = FileManager.default
            let tempDirectory = fileManager.temporaryDirectory
            let videoUrl = tempDirectory.appendingPathComponent(videoId)
            if fileManager.fileExists(atPath: videoUrl.path) {
                print("Video already downloaded")
                player = AVPlayer(url: videoUrl)
                return
            }

            Networker.downloadVideo(id: videoId) { data in
                do {
                    try data.write(to: videoUrl)
                    print("Successfully downloaded video")
                    self.player = AVPlayer(url: videoUrl)
                } catch {
                    print("Error writing video to temporary directory")
                }
            }
        }
    }
}
