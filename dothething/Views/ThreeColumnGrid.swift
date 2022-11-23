//
//  ThreeColumnGrid.swift
//  dothething
//
//  Created by Nathan Chan on 11/21/22.
//

import SwiftUI

protocol LoadMoreMessenger {
    func loadMore()
}

struct ThreeColumnGrid: View {
    var clips: [Clip]
    var width: CGFloat
    var loadMoreMessenger: LoadMoreMessenger
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem](repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                ForEach(clips, id: \.self) { clip in
                    NavigationLink {
                        VideoView(clip: clip)
                            .environmentObject(VideoViewModel(clips: clips))
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
            
            Button(action: {
                loadMoreMessenger.loadMore()
            }) {
                Text("load more")
                    .font(.custom("Montserrat-Light", size: 16))
                    .foregroundColor(Color.accentColor)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .opacity(clips.isEmpty ? 0 : 1)
            }
        }
    }
}

struct ThreeColumnGrid_Previews: PreviewProvider {
    static var previews: some View {
        ThreeColumnGrid(clips: [], width: 1080, loadMoreMessenger: ProfileView.ProfileViewModel())
    }
}
