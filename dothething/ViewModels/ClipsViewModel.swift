//
//  ClipsViewModel.swift
//  dothething
//
//  Created by Nathan Chan on 11/2/22.
//

import SwiftUI

struct ClipMetadata: Codable, Hashable {
    let code: String
    let id: String
    let timeOfCreation: String
    let thumbnailBase64: String
}

struct Clip: Hashable {
    let thumbnail: UIImage
    let isHighlighted: Bool
    let metadata: ClipMetadata
    let showCode: Bool
    
    init(thumbnail: UIImage, isHighlighted: Bool, metadata: ClipMetadata, showCode: Bool) {
        self.thumbnail = thumbnail
        self.isHighlighted = isHighlighted
        self.metadata = metadata
        self.showCode = showCode
    }
}

class ClipsViewModel: ObservableObject, ImagePickerMessenger {
    @Published var clips: [Clip] = [
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=QH2-TGUlwu4") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: true, showCode: false),
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=9bZkp7q19f0") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false, showCode: false),
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=p3G5IXn0K7A") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false, showCode: false),
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=sXWjwUl949Y") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false, showCode: false),
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=h7MYJghRWt0") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false, showCode: false),
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=njos57IJf-0") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false, showCode: false),
    ]
    @Published var errorText = ""
    @Published var code = ""
    @Published var isLoading = false
    @Published var buttonText = "place a domino"

    private var didUpload = true
    private var codeInternal = ""
    private var videoDegreesToRotate = -90
    private lazy var imagePicker = ImagePicker(messenger: self)

    init() {
        print("Initializing ClipsViewModel")
    }

    func onAppear(code: String) {
        if code.isEmpty && self.codeInternal.isEmpty {
            print("Entered ClipsView onAppear with empty code")
            imagePicker.open()
        } else if self.clips.isEmpty || self.code != code || self.codeInternal != code {
            print("Entered ClipsView.onAppear: code=\(code)")
            self.clips = []
            self.code = code
            self.codeInternal = code
            self.downloadExistingThing()
        }
        // otherwise ignore this onAppear if clips is not empty
    }
    
    private func clearStorage() {
        DispatchQueue.main.async {
            self.clips = []
        }
    }
    
    func backButtonPressed() {
        print("Back button pressed")
        clearStorage()
    }
    
    func uploadButtonPressed() {
        print("Upload button pressed")
        imagePicker.open()
    }
    
    func shareButtonPressed() {
        print("Share button pressed")
        Thinger.showSharePopup(text: "I added my domino. Join the cascade with code \(codeInternal) on thedominoapp.com!")
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

    // DEFCON 1
    func downloadExistingThing() {
        print("Entered downloadExistingThing")
        print("Code: \(codeInternal)")
        startLoading()

        Networker.downloadExistingThing(code: codeInternal, batchIndex: 0) { cmdArray in // clips metadata array
            print("Downloaded \(cmdArray.count) clips")
            if cmdArray.isEmpty {
                self.handleError(errorCode: "INVALID_CODE")
                return
            } else {
                for cmd in cmdArray {
                    let dataDecoded = Data(base64Encoded: cmd.thumbnailBase64, options: .ignoreUnknownCharacters)
                    let decodedimage = UIImage(data: dataDecoded ?? Data())
                    let clip = Clip(thumbnail: decodedimage ?? UIImage(), isHighlighted: false, metadata: cmd, showCode: false)
                    DispatchQueue.main.async {
                        self.clips.append(clip)
                    }
                }
                DispatchQueue.main.async {
                    self.stopLoading()
                }
            }
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
