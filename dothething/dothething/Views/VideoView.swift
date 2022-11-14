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
                    videoViewModel.player.play()
                }
                .onDisappear {
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
        VideoView(videoViewModel: VideoView.VideoViewModel(videoUrl: URL(fileURLWithPath: "")))
    }
}

extension VideoView {
    class VideoViewModel: ObservableObject {
        @Published var player = AVPlayer()
        
        private var videoUrl: URL
        
        init(videoUrl: URL) {
            self.videoUrl = videoUrl
            player = AVPlayer(url: videoUrl)
        }
    }
}
