//
//  HomeView.swift
//  dothething
//
//  Created by Nathan Chan on 10/20/22.
//

import SwiftUI
import ZipArchive

struct ClipView: View {
    let clip: Clip

    var body: some View {
        // thumbnail of video
        Image(uiImage: clip.thumbnail)
            .resizable()
            .frame(width: 108, height: 192)
            .cornerRadius(8)
            .onTapGesture {
                print("Tapped \(clip.url)")
                Thinger.playVideo(videoUrl: clip.url)
            }
        // add a border to the thumbnail
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.red, lineWidth: clip.isHighlighted ? 8 : 0)
        )
    }
}

struct ClipsView: View {
    @ObservedObject private(set) var clipsViewModel: ClipsViewModel
    @Binding var code: String
    @Binding var toggle: Bool
    
    var body: some View {
        VStack {
            HStack {
                // back button
                Button(action: {
                    print("Back button tapped")
                    clipsViewModel.backButtonPressed()
                    toggle.toggle()
                }) {
                    Text("Back")
                }
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // upload button
                Button(action: {
                    clipsViewModel.uploadButtonPressed()
                }) {
                    Text("Upload")
                }
                .opacity(clipsViewModel.uploadDisabled ? 0.5 : 1)

                // share button
                Button(action: {
                    clipsViewModel.shareButtonPressed()
                }) {
                    Text("Share")
                }
                .padding(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .opacity(clipsViewModel.shareDisabled ? 0.5 : 1)
            }

            if clipsViewModel.isLoading {
                ProgressView()
                    .scaleEffect(x: 2, y: 2, anchor: .center)
                    .padding(.top)
                Spacer()
            } else if !clipsViewModel.errorText.isEmpty {
                Text(clipsViewModel.errorText)
                    .padding(.top)
                    .foregroundColor(Color(UIColor.systemGray))
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 108, maximum: 108), spacing: 16)]) {
                        ForEach(clipsViewModel.clips, id: \.self) { clip in
                            ClipView(clip: clip)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            
            Text("Code: \(code)")
                .padding()
                .onTapGesture {
                    print("Code tapped")
                    UIPasteboard.general.string = code
                }
        }
        .onAppear {
            clipsViewModel.enterCode(code: code)
        }
    }
}

struct ClipsView_Previews: PreviewProvider {
    static var previews: some View {
        ClipsView(clipsViewModel: ClipsView.ClipsViewModel(), code: .constant(""), toggle: .constant(false))
    }
}

struct Clip: Hashable {
    let url: URL
    let thumbnail: UIImage
    let isHighlighted: Bool
    
    init(url: URL, thumbnail: UIImage, isHighlighted: Bool) {
        self.url = url
        self.thumbnail = thumbnail
        self.isHighlighted = isHighlighted
    }
}

extension ClipsView {
    class ClipsViewModel: ObservableObject {
        @Published var clips: [Clip] = [
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=QH2-TGUlwu4") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(systemName: "film") ?? UIImage(), isHighlighted: true),
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=9bZkp7q19f0") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(systemName: "film") ?? UIImage(), isHighlighted: false),
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=p3G5IXn0K7A") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(systemName: "film") ?? UIImage(), isHighlighted: false)
        ]
        @Published var isLoading = false
        @Published var shareDisabled = true
        @Published var uploadDisabled = true
        @Published var errorText = ""
        
        private var code = ""
        private var videoDegreesToRotate = -90
        private let password = "ThisIsEpicPassword"

        private lazy var imagePicker = ImagePicker(viewModel: self)

        init() {
            print("Initializing ClipsViewModel")
        }

        func enterCode(code: String) {
            if self.clips.isEmpty {
                print("Entered enterCode with code: \(code)")
                self.code = code
                self.isLoading = true
                self.downloadExistingThing()
            } else {
                print("Ignoring enterCode because clips is empty")
            }
        }
        
        func backButtonPressed() {
            self.clearStorage()
        }

        func shareButtonPressed() {
            if shareDisabled && !uploadDisabled {
                print("Share button disabled")
                self.showAlert(title: "Share", message: "Please upload your version of The Thing before you share!", button: "OK")
            }
            // will return if both are disabled (default state)
        }

        func uploadButtonPressed() {
            print("Upload button pressed")
            if uploadDisabled {
                print("Upload button disabled")
                return
            }
            self.imagePicker.open()
        }
        
        private func showAlert(title: String, message: String, button: String) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: button, style: .default, handler: nil))
                
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                let window = windowScene?.windows.first
                window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
        
        private func stopLoadingDueToError(text: String) {
            DispatchQueue.main.async {
                self.errorText = text
                self.isLoading = false
            }
        }
        
        private func handleStatusCodeError(statusCode: Int) {
            print("statusCode should be 200, but is \(statusCode)")
            if statusCode == 404 {
                self.stopLoadingDueToError(text: "Status Code 404: Invalid Code")
            } else {
                self.stopLoadingDueToError(text: "Status Code \(statusCode)")
            }
        }
        
        private func handleGenericError(errorCode: String) {
            self.stopLoadingDueToError(text: "Error Code \(errorCode)")
        }

        private func clearStorage() {
            DispatchQueue.main.async {
                self.clips = []
            }
        }

        struct ClipMetaData: Codable {
            var code: String
            var id: String
            var timestamp: String
        }

        // DEFCON 1.1
        // GET request
        // must provide "code" header
        func downloadExistingThing() {
            print("Entered downloadExistingThing")
            print("Code: \(self.code)")
//            self.clearStorage()

            // GET request to get presigned URL
            let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething") ?? URL(fileURLWithPath: "")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(self.code, forHTTPHeaderField: "code")
            request.setValue(self.password, forHTTPHeaderField: "password")

            print("Starting GET request to \(String(describing: url))")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // data validation
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    self.handleStatusCodeError(statusCode: httpStatus.statusCode)
                    return
                }
                print("response = \(String(describing: response))")

                // convert JSON
                print(data)
                let decoder = JSONDecoder()
                guard let dataArray = try? decoder.decode([ClipMetaData].self, from: data) else {
                    print("Failed to decode JSON")
                    self.handleGenericError(errorCode: "1")
                    return
                }
                print("DownloadResponse: \(dataArray)")
                
                // for each id, make a GET request to get the presigned URL
                for clip in dataArray {
                    let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething") ?? URL(fileURLWithPath: "")
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    request.setValue(clip.id, forHTTPHeaderField: "id")
                    request.setValue(self.password, forHTTPHeaderField: "password")

                    print("Starting GET request to \(String(describing: url))")
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        // data validation
                        guard let data = data, error == nil else {
                            self.handleGenericError(errorCode: "2")
                            return
                        }
                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                            self.handleStatusCodeError(statusCode: httpStatus.statusCode)
                            return
                        }
                        print("response = \(String(describing: response))")
                        
                        // convert data to string to get presigned URL
                        let presignedUrl = String(data: data, encoding: .utf8)
                        let url = URL(string: presignedUrl ?? "")
                        let request = URLRequest(url: url ?? URL(fileURLWithPath: ""))

                        // download from presigned URL
                        print("Starting GET request to \(String(describing: url))")
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            // data validation
                            guard let data = data, error == nil else {
                                self.handleGenericError(errorCode: "3")
                                return
                            }
                            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                                self.handleStatusCodeError(statusCode: httpStatus.statusCode)
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
                                self.handleGenericError(errorCode: "2")
                                return
                            }

                            // save url to clips array
                            DispatchQueue.main.async {
                                let thumbnail = Thinger.getThumbnail(url: tempFileUrl, degreesToRotate: self.videoDegreesToRotate)
                                // highlight first clip
                                if self.clips.count == 0 {
                                    self.clips.append(Clip(url: tempFileUrl, thumbnail: thumbnail, isHighlighted: true))
                                } else {
                                    self.clips.append(Clip(url: tempFileUrl, thumbnail: thumbnail, isHighlighted: false))
                                }
                                print("Added clip \(self.clips.count) out of \(dataArray.count)")

                                // if all clips have been downloaded, stop loading
                                if self.clips.count >= dataArray.count {
                                    self.isLoading = false
                                    self.uploadDisabled = false
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

        // DEFCON 2.2
        // PUT request
        // will actually put data
        // must provide "code" header
        func uploadVideo(presignedUrl: String, videoUrl: URL) {
            print("Entered uploadVideo")
            print("Presigned URL: \(presignedUrl)")
            
            // convert NSData to data
            let videoData = NSData(contentsOf: videoUrl)
            guard let data = videoData as Data? else {
                self.handleGenericError(errorCode: "F3")
                return
            }

            // alert user if video is too large (1 GB)
            if data.count > 1000000000 {
                self.handleGenericError(errorCode: "FILE_TOO_LARGE")
                return
            }

            let url = URL(string: presignedUrl)
            var request = URLRequest(url: url ?? URL(fileURLWithPath: ""))
            request.httpMethod = "PUT"

            print("Starting PUT request to \(String(describing: url))")
            let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
                // data validation
                guard let data = data, error == nil else {
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    self.handleStatusCodeError(statusCode: httpStatus.statusCode)
                    return
                }
                let responseString = String(data: data, encoding: .utf8)
                print("response = \(String(describing: response))")
                print("responseString = \(String(describing: responseString))")
            }
            task.resume()
        }
        
        // DEFCON 2.1
        // PUT request
        // doesn't actually put any data
        // must provide "code" header
        func getPresignedUrlForUploadToExistingThing(videoUrl: URL) {
            print("Entered getPresignedUrlForUploadToExistingThing")
            print("Code: \(self.code)")
            print("Video URL: \(videoUrl)")

            // get file extension of video
            let fileExtension = videoUrl.pathExtension.lowercased()
            print("File extension: \(fileExtension)")

            // PUT request to get presigned URL
            let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething") ?? URL(fileURLWithPath: "")
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue(self.code, forHTTPHeaderField: "code")
            request.setValue(fileExtension, forHTTPHeaderField: "file-extension")

            print("Starting PUT request to \(String(describing: url))")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // data validation
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    self.handleStatusCodeError(statusCode: httpStatus.statusCode)
                    return
                }
                let responseString = String(data: data, encoding: .utf8)
                print("response = \(String(describing: response))")
                print("responseString = \(String(describing: responseString))")
                
                self.uploadVideo(presignedUrl: responseString ?? "", videoUrl: videoUrl)
            }
            task.resume()
        }
        
        // DEFCON 2.0
        func upload(videoUrl: URL) {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            self.getPresignedUrlForUploadToExistingThing(videoUrl: videoUrl)
        }
        
        func getPresignedUrlForUploadToNewThing() {
            print("Entered getPresignedUrlForUploadToNewThing")
        }

        // function that will calls an API and returns 
    }
}
