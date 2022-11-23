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
                    ThreeColumnGrid(clips: clipsViewModel.clips, width: geometry.size.width, loadMoreMessenger: clipsViewModel)
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
                            .font(.custom("Montserrat-Medium", size: 24, relativeTo: .title))
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
                            .font(.custom("Montserrat-Medium", size: 24, relativeTo: .title))
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

import SwiftUI

class ClipsViewModel: ObservableObject, ImagePickerMessenger, LoadMoreMessenger {
    @Published var clips: [Clip] = []
    @Published var errorText = ""
    @Published var code = ""
    @Published var isLoading = false

    private var codeInternal = ""
    private lazy var imagePicker = ImagePicker(messenger: self)
    private var currentBatchIndex: Int = 0

    init() {
        print("Initializing ClipsViewModel")
    }

    func onAppear(code: String) {
        if code.isEmpty && self.codeInternal.isEmpty {
            print("Entered ClipsViewModel.onAppear with empty code")
            imagePicker.open()
        } else if self.clips.isEmpty || self.code != code || self.codeInternal != code {
            print("Entered ClipsViewModel.onAppear: code=\(code)")
            self.clips = []
            self.code = code
            self.codeInternal = code
            self.downloadExistingThing()
        }
        // otherwise ignore this onAppear if clips is not empty
    }
    
    private func clearStorage() {
        print("Entered ClipsViewModel.clearStorage")
        DispatchQueue.main.async {
            self.clips = []
            self.errorText = ""
        }
    }
    
    func backButtonPressed() {
        print("Entered ClipsViewModel.backButtonPressed")
        clearStorage()
    }
    
    func uploadButtonPressed() {
        print("Entered ClipsViewModel.uploadButtonPressed")
        imagePicker.open()
    }
    
    func shareButtonPressed() {
        print("Entered ClipsViewModel.shareButtonPressed")
        Networker.getShareMessage(code: codeInternal) { message in
            if message.isEmpty {
                let msg = "Check out this domino cascade that I made! Use code \(self.codeInternal) to join: https://master.d1yarv3zeb5tjh.amplifyapp.com/?code=\(self.codeInternal)"
                Thinger.showSharePopup(text: msg)
            } else {
                Thinger.showSharePopup(text: message)
            }
        }
    }

    private func handleError(errorCode: String, logMessage: String = "") {
        if errorCode == "E21-409" {
            Thinger.showAlert(title: "You've already uploaded to this cascade!", message: "", button: "OK")
        }
        DispatchQueue.main.async {
            self.stopLoading()
            self.errorText = "Error Code \(errorCode)"
            print("Error Code \(errorCode) \(logMessage)")
        }
    }
    
    private func startLoading() {
        DispatchQueue.main.async {
            self.errorText = ""
            self.isLoading = true
        }
    }
    
    private func stopLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func loadMore() {
        print("Entered ClipsViewModel.loadMore")
        currentBatchIndex += 1
        downloadExistingThing()
    }

    // DEFCON 1
    func downloadExistingThing() {
        print("Entered ClipsViewModel.downloadExistingThing")
        print("Code: \(codeInternal)")
        startLoading()

        Networker.downloadExistingThing(code: codeInternal, batchIndex: currentBatchIndex) { cmdArray in // clips metadata array
            print("Downloaded \(cmdArray.count) clips")
            if cmdArray.isEmpty && self.currentBatchIndex > 0 {
                self.currentBatchIndex -= 1
            } else if cmdArray.isEmpty {
                self.handleError(errorCode: "INVALID_CODE")
                return
            } else {
                DispatchQueue.main.async {
                    self.clips.append(contentsOf: Thinger.clipsMetadataArrayToClipsArray(cmdArray: cmdArray))
                }
            }
            self.stopLoading()
        }
    }

    func refresh() {
        print("Entered ClipsViewModel.refresh")
        clearStorage()
        downloadExistingThing()
    }
    
    // DEFCON 2
    func uploadToExistingThing(videoUrl: URL) {
        startLoading()
        print("Entered ClipsViewModel.uploadToExistingThing")
        print("Code: \(self.codeInternal)")
        print("Video URL: \(videoUrl)")

        // get file extension of video
        let fileExtension = videoUrl.pathExtension.lowercased()
        print("File extension: \(fileExtension)")

        // PUT request to get presigned URL
        let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething")
        guard let url = url else {
            self.handleError(errorCode: "E1")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(self.codeInternal, forHTTPHeaderField: "code")
        request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")
        request.setValue(fileExtension, forHTTPHeaderField: "file-extension")
        request.setValue(GlobalConfig.shared.sessionId, forHTTPHeaderField: "session-id")

        print("Starting PUT request to \(String(describing: url))")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // data validation
            guard let data = data, error == nil else {
                self.handleError(errorCode: "E2")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                self.handleError(errorCode: "E21-\(httpStatus.statusCode)")
                return
            }

            // convert data to string to get presigned URL
            let presignedUrl = String(data: data, encoding: .utf8)
            guard let presignedUrl = presignedUrl else {
                self.handleError(errorCode: "E3")
                return
            }
            print("Presigned URL: \(String(describing: presignedUrl))")
            
            // convert NSData to data
            let videoData = NSData(contentsOf: videoUrl)
            guard let data = videoData as Data? else {
                self.handleError(errorCode: "E4")
                return
            }

            // alert user if video is too large (0.1 GB)
            if data.count > 100000000 {
                self.handleError(errorCode: "FILE_TOO_LARGE")
                return
            }

            let url = URL(string: presignedUrl)
            guard let url = url else {
                self.handleError(errorCode: "E5")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"

            print("Starting PUT request to \(String(describing: url))")
            let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    self.handleError(errorCode: "E51-\(httpStatus.statusCode)")
                    return
                }

                // reload everything
                self.clearStorage()
                sleep(1)
                self.downloadExistingThing()
            }
            task.resume()
        }
        task.resume()
    }
    
    // DEFCON 3
    private func uploadToNewThing(videoUrl: URL) {
        startLoading()
        print("Entered ClipsViewModel.uploadToNewThing")

        // get file extension of video
        let fileExtension = videoUrl.pathExtension.lowercased()
        print("File extension: \(fileExtension)")

        // POST request to get presigned URL for new thing
        let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething")
        guard let url = url else {
            self.handleError(errorCode: "F1")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")
        request.setValue(fileExtension, forHTTPHeaderField: "file-extension")
        request.setValue(GlobalConfig.shared.sessionId, forHTTPHeaderField: "session-id")

        print("Starting POST request to \(String(describing: url))")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                self.handleError(errorCode: "F2")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                self.handleError(errorCode: "F21-\(httpStatus.statusCode)")
                return
            }

            // convert data to string to get presigned URL
            let presignedUrl = String(data: data, encoding: .utf8)
            guard let presignedUrl = presignedUrl else {
                self.handleError(errorCode: "F3")
                return
            }
            print("Presigned URL: \(String(describing: presignedUrl))")

            // parse presigned URL to get code
            var parsedCode = presignedUrl.components(separatedBy: "/").last!
            parsedCode = parsedCode.components(separatedBy: "-").first!
            print("Parsed code: \(parsedCode)")

            // convert NSData to data
            let videoData = NSData(contentsOf: videoUrl)
            guard let data = videoData as Data? else {
                self.handleError(errorCode: "F4")
                return
            }

            // alert user if video is too large (0.1 GB)
            if data.count > 100000000 {
                self.handleError(errorCode: "FILE_TOO_LARGE")
                return
            }

            let url = URL(string: presignedUrl)
            guard let url = url else {
                self.handleError(errorCode: "E5")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"

            print("Starting PUT request to \(String(describing: url))")
            let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    self.handleError(errorCode: "E51-\(httpStatus.statusCode)")
                    return
                }

                // reload everything
                // need to use codeInternal because code needs to be updated in main thread,
                // which would prevent the downloadExistingThing() call from working
                self.codeInternal = parsedCode
                DispatchQueue.main.async {
                    self.code = parsedCode
                }
                sleep(3)
                self.clearStorage()
                self.downloadExistingThing()
            }
            task.resume()
        }
        task.resume()
    }
    
    // DEFCON 2 OR 3
    func upload(videoUrl: URL) {
        if self.code.isEmpty {
            self.uploadToNewThing(videoUrl: videoUrl)
        } else {
            self.uploadToExistingThing(videoUrl: videoUrl)
        }
    }

    func cancel() {
    }
}

