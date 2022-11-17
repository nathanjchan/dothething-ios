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
                                // get image asynchronously
                                AsyncImage(url: profilePicture) { image in
                                    image
                                        .resizable()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(lineWidth: 6)
                                                .frame(width: 126, height: 126)
                                                .colorInvert()
                                        )
                                } placeholder: {
                                    ZStack {
                                        Circle()
                                            .frame(width: 120, height: 120)
                                            .foregroundColor(.gray)
                                            .overlay(
                                                Circle()
                                                    .stroke(lineWidth: 6)
                                                    .frame(width: 126, height: 126)
                                                    .colorInvert()
                                            )
                                        
                                        ProgressView()
                                    }
                                    
                                }
                            } else {
                                Circle()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray)
                                    .overlay(
                                        Circle()
                                            .stroke(lineWidth: 6)
                                            .frame(width: 126, height: 126)
                                            .colorInvert()
                                    )
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(GlobalConfig.shared.name ?? "No Name")
                                
                                Text("sign out")
                                    .onTapGesture {
                                        print("Sign out button pressed")
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
                        ScrollView {
                            LazyVGrid(columns: [GridItem](repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                                ForEach(profileViewModel.clips, id: \.self) { clip in
                                    NavigationLink {
                                        VideoView(videoViewModel: VideoView.VideoViewModel(videoId: clip.metadata.id))
                                    } label: {
                                        ClipView(clip: clip)

                                    }
                                }
                                .frame(height: (192 / 108) * geometry.size.width / 3)
                            }
                            .padding(.leading, 4)
                            .padding(.trailing, 4)
                        }
//                        .padding(.top, -16)
//                        .padding(.bottom, -12)
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

        private var videoDegreesToRotate = -90

        init() {
            print("Initializing ProfileViewModel")
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
            Networker.downloadProfileClips() { cmdArray in 
                print("Downloaded \(cmdArray.count) clips: \(cmdArray)")
                for cmd in cmdArray {
                    usleep(100000) // 0.1 seconds
                    Networker.downloadThumbnail(urlString: cmd.thumbnailUrl) { thumbnail in
                        let clip = Clip(thumbnail: thumbnail, isHighlighted: false, metadata: cmd, showCode: false)
                        DispatchQueue.main.async {
                            self.clips.append(clip)
                        }
                        self.isLoading = false
                    }
                }
            }
        }   
    }
}
