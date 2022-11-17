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
                    
            VStack() {
                
                Spacer()
                
                Button(action: {
                }, label: {
                    Text("view profile")
                        .font(.custom("Montserrat-Medium", size: 16))
                        .foregroundColor(.accentColor)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.accentColor.colorInvert())
                        .cornerRadius(10)
                })
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
            // TODO: check that the ID is not currently saved to temporary directory
            // TODO: use Networker to get the presigned URL with video
            // TODO: use Networker to download video
            // TODO: save video to temporary directory with id

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
                    print("Video downloaded")
                    self.player = AVPlayer(url: videoUrl)
                } catch {
                    print("Error writing video to temporary directory")
                }
            }
        }
    }
}
