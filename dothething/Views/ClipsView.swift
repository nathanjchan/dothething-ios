//
//  HomeView.swift
//  dothething
//
//  Created by Nathan Chan on 10/20/22.
//

import SwiftUI

struct ClipView: View {
    let clip: Clip
//    @State var showVideoView = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if clip.thumbnail == UIImage() {
                    Image("Placeholder")
                        .resizable()
                } else {
                    Image(uiImage: clip.thumbnail)
                        .resizable()
                }
                
                if clip.showCode {
                    Rectangle()
                        .frame(height: geometry.size.height / 10)
                        .opacity(0.5)
                        .overlay {
                            Text(clip.metadata.code)
                                .colorInvert()
                                .font(.custom("Montserrat-Light", size: 18))
                        }
                }
            }
        }
    }
}

struct ClipsView: View {
    @EnvironmentObject var clipsViewModel: ClipsViewModel
    @Binding var code: String
    
    var body: some View {
        GeometryReader { geometry in
                
            VStack {
                if clipsViewModel.code.isEmpty {
                    Text("nothing here yet...")
                        .font(.custom("Montserrat-Italic", size: 24))
                        .padding()
                }
                
                if !clipsViewModel.errorText.isEmpty && clipsViewModel.clips.isEmpty {
                    Text(clipsViewModel.errorText)
                        .padding(.top)
                        .foregroundColor(Color(UIColor.systemGray))
                } else if clipsViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding()
                }
                
                NavigationStack {
                    ScrollView {
                        LazyVGrid(columns: [GridItem](repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                            ForEach(clipsViewModel.clips, id: \.self) { clip in
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
                                        }
                                        .navigationBarTitleDisplayMode(.inline)
                                        .toolbarBackground(.visible)
                                } label: {
                                    ClipView(clip: clip)
                                }
                            }
                            .frame(height: (192 / 108) * geometry.size.width / 3)
                        }
                        .padding(.leading, 4)
                        .padding(.trailing, 4)
                    }
                    .padding(.bottom, -12)
                }

                ZStack {
                    Rectangle()
                        .frame(height: 36)
                        .foregroundColor(.accentColor)
                    
                    Text("\(clipsViewModel.code)")
                        .font(.custom("Montserrat-Light", size: 18))
                        .foregroundColor(.accentColor)
                        .colorInvert()
                        .textSelection(.enabled)
                }
                .opacity(clipsViewModel.code.isEmpty ? 0 : 1)
                
                HStack {
                    Button(action: {
                        clipsViewModel.uploadButtonPressed()
                    }) {
                        Text("upload")
                            .font(.custom("Montserrat-Light", size: 24, relativeTo: .title))
                            .foregroundColor(.accentColor)
                            .colorInvert()
                            .padding()
                            .frame(width: 150, height: 36)
                            .background(Color.accentColor)
                            .cornerRadius(50)
                    }
                    .opacity(clipsViewModel.uploadEnabled ? 1 : 0.5)
                    
                    Button(action: {
                        clipsViewModel.shareButtonPressed()
                    }) {
                        Text("share")
                            .font(.custom("Montserrat-Light", size: 24, relativeTo: .title))
                            .foregroundColor(.accentColor)
                            .colorInvert()
                            .padding()
                            .frame(width: 150, height: 36)
                            .background(Color.accentColor)
                            .cornerRadius(50)
                    }
                    .opacity(clipsViewModel.shareEnabled ? 1 : 0.5)
                }
                .opacity(clipsViewModel.code.isEmpty ? 0 : 1)
            }
            .onAppear {
                clipsViewModel.onAppear(code: code)
            }
        }
    }
}

struct ClipsView_Previews: PreviewProvider {
    static var previews: some View {
        ClipsView(code: .constant("dothethingtest"))
            .environmentObject(ClipsViewModel())
    }
}