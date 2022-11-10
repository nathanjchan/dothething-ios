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
    @Binding var currentView: CurrentView

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Button(action: {
                        print("Back button tapped")
                        currentView = .home
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .foregroundColor(.accentColor)
                    }

                    if let profilePicture = GlobalConfig.shared.profilePicture {
                        // get image asynchronously
                        AsyncImage(url: profilePicture) { image in
                            image
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Image(systemName: "person.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.accentColor)
                    }

                    Text(GlobalConfig.shared.name ?? "no name")

                    Button(action:{
                        print("Sign out button tapped")
                        authViewModel.handleSignOutButton()
                    }) {
                        Text("sign out")
                    }
                }

                if profileViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(.top)
                }

                ScrollView {
                    LazyVGrid(columns: [GridItem](repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                        ForEach(profileViewModel.clips, id: \.self) { clip in
                            ClipView(clip: clip)
                        }
                        .frame(height: (192 / 108) * geometry.size.width / 3)
                    }
                    .padding(.leading, 4)
                    .padding(.trailing, 4)
                }
                .padding(.top, -16)
                .padding(.bottom, -12)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(currentView: .constant(.profile))
            .environmentObject(AuthenticationViewModel())
            .environmentObject(ProfileView.ProfileViewModel())
    }
}

extension ProfileView {
    class ProfileViewModel: ObservableObject {
        @Published var clips: [Clip] = [
            // Clip(url: URL(string: "https://www.youtube.com/watch?v=QH2-TGUlwu4") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false),
            // Clip(url: URL(string: "https://www.youtube.com/watch?v=9bZkp7q19f0") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false),
            // Clip(url: URL(string: "https://www.youtube.com/watch?v=p3G5IXn0K7A") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false),
            // Clip(url: URL(string: "https://www.youtube.com/watch?v=sXWjwUl949Y") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false),
            // Clip(url: URL(string: "https://www.youtube.com/watch?v=h7MYJghRWt0") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false),
            // Clip(url: URL(string: "https://www.youtube.com/watch?v=njos57IJf-0") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false),
        ]
        @Published var isLoading = false
        @Published var errorText = ""

        private var videoDegreesToRotate = -90

        init() {
            self.fetchClips()
        }

        private func handleError(errorCode: String, logMessage: String = "") {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorText = "Error Code \(errorCode)"
                print("Error Code \(errorCode) \(logMessage)")
            }
        }

        private func fetchClips() {
            print("Entered fetchClips")
            self.isLoading = true

            guard let sessionId = GlobalConfig.shared.sessionId else { return }

            // GET request to get presigned URLs
            let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething") ?? URL(fileURLWithPath: "")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(sessionId, forHTTPHeaderField: "session-id")
            request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")

            print("Starting GET request to \(String(describing: url))")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // data validation
                guard let data = data, error == nil else {
                    self.handleError(errorCode: "C1")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    self.handleError(errorCode: "C11-\(httpStatus.statusCode)")
                    return
                }

                // convert JSON
                let decoder = JSONDecoder()
                guard let dataArray = try? decoder.decode([ClipMetadata].self, from: data) else {
                    print("Failed to decode JSON")
                    self.handleError(errorCode: "C2")
                    return
                }
                print("DownloadResponse: \(dataArray)")
                
                // handle empty response
                if dataArray.isEmpty {
                    self.handleError(errorCode: "INVALID_CODE")
                    return
                }
                
                // for each id, make a GET request to get the presigned URL
                for clip in dataArray {
                    // wait for 0.1 seconds to avoid rate limiting
                    usleep(100000)

                    let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething") ?? URL(fileURLWithPath: "")
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    request.setValue(clip.id, forHTTPHeaderField: "id")
                    request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")

                    print("Starting GET request to \(String(describing: url))")
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        // data validation
                        guard let data = data, error == nil else {
                            self.handleError(errorCode: "C3")
                            return
                        }
                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                            self.handleError(errorCode: "C31-\(httpStatus.statusCode)")
                            return
                        }
                        
                        // convert data to string to get presigned URL
                        let presignedUrl = String(data: data, encoding: .utf8)
                        let url = URL(string: presignedUrl ?? "")
                        let request = URLRequest(url: url ?? URL(fileURLWithPath: ""))

                        // download from presigned URL
                        print("Starting GET request to \(String(describing: url))")
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            // data validation
                            guard let data = data, error == nil else {
                                self.handleError(errorCode: "C4")
                                return
                            }
                            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                                self.handleError(errorCode: "C41-\(httpStatus.statusCode)")
                                return
                            }

                            // save data to file in temporary directory
                            let fileManager = FileManager.default
                            let tempDirectory = fileManager.temporaryDirectory
                            let tempFileUrl = tempDirectory.appendingPathComponent(clip.id)
                            do {
                                try data.write(to: tempFileUrl)
                                print("Saved data to \(tempFileUrl)")
                            } catch {
                                print("Error saving data to \(tempFileUrl)")
                                self.handleError(errorCode: "C5")
                                return
                            }

                            // save url to clips array
                            DispatchQueue.main.async {
                                let thumbnail = Thinger.getThumbnail(url: tempFileUrl, degreesToRotate: self.videoDegreesToRotate)
                                self.clips.append(Clip(url: tempFileUrl, thumbnail: thumbnail, isHighlighted: false, metadata: clip))
                                print("Added clip \(self.clips.count) out of \(dataArray.count)")

                                // if all clips have been downloaded, stop loading
                                if self.clips.count >= dataArray.count {
                                    self.isLoading = false
                                }
                            }
                        }
                        task.resume()
                    }
                    task.resume()
                }
            }
            task.resume()
        }   
    }
}
