//
//  ClipsViewModel.swift
//  dothething
//
//  Created by Nathan Chan on 11/2/22.
//

import SwiftUI

class ClipsViewModel: ObservableObject, ImagePickerMessenger {
    @Published var clips: [Clip] = [
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=QH2-TGUlwu4") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: true),
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=9bZkp7q19f0") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false),
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=p3G5IXn0K7A") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false),
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=sXWjwUl949Y") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false),
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=h7MYJghRWt0") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false),
//            Clip(url: URL(string: "https://www.youtube.com/watch?v=njos57IJf-0") ?? URL(fileURLWithPath: ""), thumbnail: UIImage(), isHighlighted: false),
    ]
    @Published var shareDisabled = true
    @Published var uploadDisabled = true
    @Published var errorText = ""
    @Published var code = ""
    @Published var isLoading = false
    @Published var buttonText = "place a domino"

    private var codeInternal = ""
    private var videoDegreesToRotate = -90
    private lazy var imagePicker = ImagePicker(messenger: self)

    init() {
        print("Initializing ClipsViewModel")
    }

    func onAppear(code: String) {
        print("Entered ClipsViewModel onAppear")
        if code.isEmpty && self.codeInternal.isEmpty {
            print("Entered ClipsView onAppear with empty code")
            self.openImagePicker()
        } else {
            if self.clips.isEmpty {
                print("Entered ClipsView onAppear with code: \(code)")
                self.code = code
                self.codeInternal = code
                self.downloadExistingThing()
            } else {
                print("Ignoring ClipsView on appear because clips is not empty")
            }
        }
    }
    
    private func clearStorage() {
        DispatchQueue.main.async {
            self.clips = []
        }
    }
    
    func openImagePicker() {
        self.imagePicker.open()
    }
    
    func backButtonPressed() {
        self.clearStorage()
    }

    func shareButtonPressed() {
        if shareDisabled && !uploadDisabled {
            print("Share button disabled")
            Thinger.showAlert(title: "Share", message: "Please upload your version of The Thing before you share!", button: "OK")
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

    private func handleError(errorCode: String, logMessage: String = "") {
        if errorCode == "E21-409" {
            Thinger.showAlert(title: "You've already uploaded to this cascade!", message: "", button: "OK")
        }
        DispatchQueue.main.async {
            self.isLoading = false
            self.uploadDisabled = false
            self.errorText = "Error Code \(errorCode)"
            print("Error Code \(errorCode) \(logMessage)")
        }
    }

    // DEFCON 1
    func downloadExistingThing() {
        DispatchQueue.main.async {
            self.isLoading = true
            self.uploadDisabled = true
        }
        print("Entered downloadExistingThing")
        print("Code: \(self.codeInternal)")

        // GET request to get presigned URL
        let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething") ?? URL(fileURLWithPath: "")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(self.codeInternal, forHTTPHeaderField: "code")
        request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")

        print("Starting GET request to \(String(describing: url))")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // data validation
            guard let data = data, error == nil else {
                self.handleError(errorCode: "D1")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                self.handleError(errorCode: "D11-\(httpStatus.statusCode)")
                return
            }

            // convert JSON
            let decoder = JSONDecoder()
            guard let dataArray = try? decoder.decode([ClipMetaData].self, from: data) else {
                print("Failed to decode JSON")
                self.handleError(errorCode: "D2")
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
                        self.handleError(errorCode: "D3")
                        return
                    }
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        self.handleError(errorCode: "D31-\(httpStatus.statusCode)")
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
                            self.handleError(errorCode: "D4")
                            return
                        }
                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                            self.handleError(errorCode: "D41-\(httpStatus.statusCode)")
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
                            self.handleError(errorCode: "D5")
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
                                self.uploadDisabled = false
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
    
    // DEFCON 2
    func uploadToExistingThing(videoUrl: URL) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.uploadDisabled = true
        }
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
                sleep(3)
                self.downloadExistingThing()
            }
            task.resume()
        }
        task.resume()
    }
    
    // DEFCON 3
    private func uploadToNewThing(videoUrl: URL) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.uploadDisabled = true
        }
        print("Entered HomeViewModel.uploadToNewThing")

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
}