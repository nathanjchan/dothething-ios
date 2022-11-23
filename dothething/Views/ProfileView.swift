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
                    
                    if profileViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding()
                    }
                    
                    NavigationStack {
                        ThreeColumnGrid(clips: profileViewModel.clips, width: geometry.size.width)
                            .padding(.top, -8)
                    }
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
    class ProfileViewModel: ObservableObject {
        @Published var clips: [Clip] = [
            // Clip(url: URL(string: "https://www.youtube.com/watch?v=QH2-TGUlwu4") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false, showCode: true),
            // Clip(url: URL(string: "https://www.youtube.com/watch?v=9bZkp7q19f0") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false, showCode: true),
            // Clip(url: URL(string: "https://www.youtube.com/watch?v=p3G5IXn0K7A") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false, showCode: true),
            // Clip(url: URL(string: "https://www.youtube.com/watch?v=sXWjwUl949Y") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false, showCode: true),
            // Clip(url: URL(string: "https://www.youtube.com/watch?v=h7MYJghRWt0") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false, showCode: true),
            // Clip(url: URL(string: "https://www.youtube.com/watch?v=njos57IJf-0") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false, showCode: true),
        ]
        @Published var isLoading = false
        @Published var errorText = ""

        init() {
            print("Initializing ProfileViewModel")
        }
        
        func clearStorage() {
            print("Entered ProfileViewModel.clearStorage")
            DispatchQueue.main.async {
                self.clips = []
                self.errorText = ""
            }
        }

        private func handleError(errorCode: String, logMessage: String = "") {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorText = "Error Code \(errorCode)"
                print("Error Code \(errorCode) \(logMessage)")
            }
        }
        
        func handleOnAppear() {
            if clips.isEmpty && !isLoading {
                fetchClips()
            }
        }

        private func fetchClips() {
            print("Entered ProfileViewModel.fetchClips")
            self.isLoading = true
            Networker.downloadProfileClips(batchIndex: 0) { cmdArray in 
                print("Downloaded \(cmdArray.count) clips")
                DispatchQueue.main.async {
                    self.clips = Thinger.clipsMetadataArrayToClipsArray(cmdArray: cmdArray)
                    self.isLoading = false
                }
            }
        }

        func refresh() {
            DispatchQueue.main.async {
                self.clips = []
            }
            fetchClips()
        }
    }
}
