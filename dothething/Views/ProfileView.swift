//
//  ProfileView.swift
//  dothething
//
//  Created by Nathan Chan on 11/4/22.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel

    struct CircleBorder: View {
        var body: some View {
            Circle()
                .stroke(lineWidth: 6)
                .frame(width: 126, height: 126)
                .colorInvert()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    
                    ZStack {
                        Rectangle()
                            .frame(height: 20)
                            .offset(y: -50)
                        
                        Rectangle()
                            .frame(height: 20)
                            .offset(y: 50)
                        
                        HStack {
                            if let profilePicture = GlobalConfig.shared.profilePicture {
                                Image(uiImage: profilePicture)
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(CircleBorder())
                            } else {
                                Circle()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray)
                                    .overlay(CircleBorder())
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(GlobalConfig.shared.name ?? "No Name")
                                
                                Text("sign out")
                                    .onTapGesture {
                                        authViewModel.handleSignOutButton()
                                    }
                            }
                            .font(.custom("Montserrat-Medium", size: 16))
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    ThreeColumnGrid(clips: profileViewModel.clips, width: geometry.size.width, loadMoreMessenger: profileViewModel)
                        .padding(.top, -8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("domino")
                            .font(.custom("Montserrat-Medium", size: 20))
                            .foregroundColor(Color.accentColor)
                            .tracking(8)
                        
                        Text("creator")
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundColor(Color.accentColor)
                            .tracking(4)
                    }
                    .offset(x: 4, y: -4)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        profileViewModel.refresh()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(Font.custom("Montserrat-Light", size: 16))
                            .foregroundColor(Color.accentColor)
                    }
                }
            }
        }
        .onAppear {
            profileViewModel.handleOnAppear()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(ProfileView.ProfileViewModel())
    }
}

extension ProfileView {
    class ProfileViewModel: ObservableObject, LoadMoreMessenger {
        @Published var clips: [Clip] = []
        @Published var errorText = ""
        private var didFirstLoad: Bool = false
        private var currentBatchIndex: Int = 0

        init() {
            print(#function)
        }
        
        func clearStorage() {
            print(#function)
            DispatchQueue.main.async {
                self.clips = []
                self.errorText = ""
                self.didFirstLoad = false
            }
        }

        private func handleError(errorCode: String, logMessage: String = "") {
            print(#function)
            DispatchQueue.main.async {
                self.errorText = "Error Code \(errorCode)"
                print("Error Code \(errorCode) \(logMessage)")
            }
        }
        
        func handleOnAppear() {
            print(#function)
            if !didFirstLoad {
                didFirstLoad = true
                fetchClips()
            }
        }

        private func fetchClips() {
            print(#function)
            print("currentBatchIndex=\(currentBatchIndex)")
            Networker.downloadProfileClips(batchIndex: currentBatchIndex) { cmdArray in
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

        func refresh() {
            print(#function)
            DispatchQueue.main.async {
                self.clips = []
            }
            fetchClips()
        }
        
        func loadMore() {
            print(#function)
            currentBatchIndex += 1
            fetchClips()
        }
    }
}
