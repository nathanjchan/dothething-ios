//
//  HomeView.swift
//  dothething
//
//  Created by Nathan Chan on 10/19/22.
//

import SwiftUI

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
                Text("dominos in your cascades: \(homeViewModel.interactions)")
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
                
                NavigationStack {
                    ThreeColumnGrid(clips: homeViewModel.clips, width: geometry.size.width, loadMoreMessenger: homeViewModel)
                        .padding(.top, -8)
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
    class HomeViewModel: ObservableObject, LoadMoreMessenger {
        @Published var clips: [Clip] = []
        @Published var interactions: Int = 0
        private var didFirstLoad: Bool = false
        private var currentBatchIndex: Int = 0

        init() {
            print(#function)
        }
        
        func clearStorage() {
            print(#function)
            DispatchQueue.main.async {
                self.clips = []
                self.interactions = 0
                self.didFirstLoad = false
            }
        }
        
        func handleOnAppear() {
            print(#function)
            if !didFirstLoad {
                didFirstLoad = true
                getInteractions()
                getHomeFeed()
            }
        }
        
        func refresh() {
            print(#function)
            DispatchQueue.main.async {
                self.clips = []
            }
            getInteractions()
            getHomeFeed()
        }
        
        func getInteractions() {
            print(#function)
            Networker.getInteractions { number in
                print("Number of interactions: \(number)")
                DispatchQueue.main.async {
                    self.interactions = number
                }
            }
        }

        func getHomeFeed() {
            print(#function)
            print("currentBatchIndex=\(currentBatchIndex)")
            Networker.getHomeFeed(batchIndex: currentBatchIndex) { cmdArray in
                print("Downloaded \(cmdArray.count) clips")
                if cmdArray.isEmpty && self.currentBatchIndex > 0 {
                    self.currentBatchIndex -= 1
                } else {
                    DispatchQueue.main.async {
                        self.clips.append(contentsOf: Thinger.clipsMetadataArrayToClipsArray(cmdArray: cmdArray))
                    }
                }
            }
        }
        
        func loadMore() {
            print(#function)
            currentBatchIndex += 1
            getHomeFeed()
        }
    }
}
