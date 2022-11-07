//
//  HomeView.swift
//  dothething
//
//  Created by Nathan Chan on 10/20/22.
//

import SwiftUI

struct ClipView: View {
    let clip: Clip

    var body: some View {
        GeometryReader { geometry in
            if clip.thumbnail == UIImage() {
                Image("Placeholder")
                    .resizable()
            } else {
                Image(uiImage: clip.thumbnail)
                    .resizable()
                    .onTapGesture {
                        print("Tapped \(clip.url)")
                        Thinger.playVideo(videoUrl: clip.url)
                    }
            }
        }
    }
}

struct ClipsView: View {
    @ObservedObject private(set) var clipsViewModel: ClipsViewModel
    @Binding var code: String
    @Binding var currentView: CurrentView
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    HStack {
                        Button(action: {
                            clipsViewModel.backButtonPressed()
                            currentView = .home
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24))
                                .foregroundColor(.accentColor)
                        }
                        .padding(.leading)
                        .offset(x: 0, y: 16)
                        Spacer()
                    }
                    
                    Text("domino")
                        .font(.custom("Montserrat-Medium", size: 27))
                        .foregroundColor(Color.accentColor)
                        .tracking(8)
                        .multilineTextAlignment(.center)
                }
                
                Text("rally")
                    .font(.custom("Montserrat-Medium", size: 17))
                    .padding(.bottom)
                    .tracking(4)

                if !clipsViewModel.errorText.isEmpty && clipsViewModel.clips.isEmpty {
                    Text(clipsViewModel.errorText)
                        .padding(.top)
                        .foregroundColor(Color(UIColor.systemGray))
                } else if clipsViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(.top)
                }
                
                ScrollView {
                    LazyVGrid(columns: [GridItem](repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                        ForEach(clipsViewModel.clips, id: \.self) { clip in
                            ClipView(clip: clip)
                        }
                        .frame(height: (192 / 108) * geometry.size.width / 3)
                    }
                    .padding(.leading, 4)
                    .padding(.trailing, 4)
                }
                .padding(.top, -16)
                .padding(.bottom, -12)
                
                ZStack {
                     Rectangle()
                        .frame(height: 40)
                        .foregroundColor(.accentColor)

                    Text("\(clipsViewModel.code)")
                        .font(.custom("Montserrat-Light", size: 20))
                        .foregroundColor(.accentColor)
                        .colorInvert()
                        .textSelection(.enabled)
                }
                
                HStack {
                    Button(action: {
                        clipsViewModel.uploadButtonPressed()
                    }) {
                        Text("upload")
                            .font(.custom("Montserrat-Light", size: 24, relativeTo: .title))
                            .foregroundColor(.accentColor)
                            .colorInvert()
                            .padding()
                            .frame(width: 150, height: 50)
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
                            .frame(width: 150, height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(50)
                    }
                    .opacity(clipsViewModel.shareEnabled ? 1 : 0.5)
                }
                
                
            }
            .onAppear {
                clipsViewModel.onAppear(code: code)
            }   
        }
    }
}

struct ClipsView_Previews: PreviewProvider {
    static var previews: some View {
        ClipsView(clipsViewModel: ClipsViewModel(), code: .constant(""), currentView: .constant(.clips))
    }
}
