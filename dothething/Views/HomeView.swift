//
//  HomeView.swift
//  dothething
//
//  Created by Nathan Chan on 10/19/22.
//

import SwiftUI

struct ThreeColumnGrid: View {
    var clips: [Clip] = []
    var width: CGFloat
    
    init(clips: [Clip], width: CGFloat) {
        self.clips = clips
        self.width = width
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem](repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                ForEach(clips, id: \.self) { clip in
                    NavigationLink {
                        VideoView(videoViewModel: VideoView.VideoViewModel(videoId: clip.metadata.id))
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    VStack {
                                        Text("domino")
                                            .font(.custom("Montserrat-Medium", size: 20))
                                            .foregroundColor(Color.accentColor)
                                            .tracking(8)
                                        
                                        Text("movie")
                                            .font(.custom("Montserrat-Medium", size: 16))
                                            .foregroundColor(Color.accentColor)
                                            .tracking(4)
                                    }
                                    .offset(x: 4, y: -4)
                                }
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Text(clip.metadata.code)
                                        .font(.custom("Montserrat-Medium", size: 12))
                                        .foregroundColor(Color.accentColor)
                                        .textSelection(.enabled)
                                }
                            }
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(.visible)
                    } label: {
                        ClipView(clip: clip)

                    }
                }
                .frame(height: (192 / 108) * width / 3)
            }
            .padding(.leading, 4)
            .padding(.trailing, 4)
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Binding var currentView: CurrentView
    
    struct CircleBorder: View {
        var body: some View {
            Circle()
                .stroke(lineWidth: 3)
                .frame(width: 63, height: 63)
                .colorInvert()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("dominos in your cascades: \(homeViewModel.interactions ?? 0)")
                    .font(.custom("Montserrat-medium", size: 16))
                    .padding(.top, 12)
                    .padding(.bottom, 4)
                
                ZStack {
                    Rectangle()
                        .frame(height: 32)
                    
                    Text("from your cascades")
                        .colorInvert()
                        .tracking(2)
                }
                .font(.custom("Montserrat-Light", size: 16))
                
                if homeViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding()
                }
                
                NavigationStack {
                    ThreeColumnGrid(clips: homeViewModel.clips, width: geometry.size.width)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("domino")
                                .font(.custom("Montserrat-Medium", size: 20))
                                .foregroundColor(Color.accentColor)
                                .tracking(8)
                            
                            Text("home")
                                .font(.custom("Montserrat-Medium", size: 16))
                                .foregroundColor(Color.accentColor)
                                .tracking(4)
                        }
                        .offset(x: 4, y: -4)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            homeViewModel.refresh()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(Font.custom("Montserrat-Light", size: 16))
                                .foregroundColor(Color.accentColor)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible)
            }
            .onAppear {
                homeViewModel.handleOnAppear()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(currentView: .constant(.home))
            .environmentObject(HomeView.HomeViewModel())
    }
}

extension HomeView {
    class HomeViewModel: ObservableObject {
        @Published var isLoading: Bool = false
        @Published var clips: [Clip] = []
        @Published var interactions: Int?

        init() {
            print("Initializing HomeViewModel")
        }
        
        func handleOnAppear() {
            getInteractions()
            if clips.isEmpty && !isLoading {
                getHomeFeed()
            }
        }
        
        func refresh() {
            getInteractions()
            DispatchQueue.main.async {
                self.clips = []
            }
            self.getHomeFeed()
        }
        
        func getInteractions() {
            print("Entered HomeViewModel.getInteractions")
            Networker.getInteractions { number in
                print("Number of interactions: \(number)")
                DispatchQueue.main.async {
                    self.interactions = number
                }
            }
        }

        func getHomeFeed() {
            print("Entered HomeViewModel.getHomeFeed")
            isLoading = true
            Networker.getHomeFeed(batchIndex: 0) { cmdArray in
                print("Downloaded \(cmdArray.count) clips")
                for cmd in cmdArray {
                    let dataDecoded = Data(base64Encoded: cmd.thumbnailBase64, options: .ignoreUnknownCharacters)
                    let decodedimage = UIImage(data: dataDecoded ?? Data())
                    let clip = Clip(thumbnail: decodedimage ?? UIImage(), isHighlighted: false, metadata: cmd, showCode: false)
                    DispatchQueue.main.async {
                        self.clips.append(clip)
                    }
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}
