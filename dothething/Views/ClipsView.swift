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
                    ThreeColumnGrid(clips: clipsViewModel.clips, width: geometry.size.width)
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
