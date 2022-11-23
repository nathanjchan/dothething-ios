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
                
                if homeViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding()
                }
                
                NavigationStack {
                    ThreeColumnGrid(clips: homeViewModel.clips, width: geometry.size.width)
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
    class HomeViewModel: ObservableObject {
        @Published var isLoading: Bool = false
        @Published var clips: [Clip] = []
        @Published var interactions: Int = 0
        private var didFirstLoad: Bool = false

        init() {
            print("Initializing HomeViewModel")
        }
        
        func clearStorage() {
            print("Entered HomeViewModel.clearStorage")
            DispatchQueue.main.async {
                self.clips = []
                self.interactions = 0
                self.didFirstLoad = false
            }
        }
        
        func handleOnAppear() {
            print("Entered HomeViewModel.handleOnAppear")
            if !didFirstLoad && !isLoading {
                didFirstLoad = true
                getInteractions()
                getHomeFeed()
            }
        }
        
        func refresh() {
            print("Entered HomeViewModel.refresh")
            getInteractions()
            getHomeFeed()
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
                DispatchQueue.main.async {
                    self.clips = Thinger.clipsMetadataArrayToClipsArray(cmdArray: cmdArray)
                    self.isLoading = false
                }
            }
        }
    }
}
