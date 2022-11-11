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
    @EnvironmentObject var clipsViewModel: ClipsViewModel
    @Binding var code: String
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
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
                .padding(.bottom, -12)
                
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
