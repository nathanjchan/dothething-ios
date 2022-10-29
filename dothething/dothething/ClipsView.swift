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
        GeometryReader { geometry in
            if clip.thumbnail == UIImage() {
                Image("Placeholder")
                    .resizable()
            } else {
                Image(uiImage: clip.thumbnail)
                    .resizable()
                    .onTapGesture {
                        print("Tapped \(clip.url)")
                        Thinger.playVideo(videoUrl: clip.url)
                    }
            }
        }
    }
}

struct ClipsView: View {
    @ObservedObject private(set) var clipsViewModel: ClipsViewModel
    @Binding var code: String
    @Binding var toggle: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    HStack {
                        Button(action: {
                            print("Back button tapped")
                            clipsViewModel.backButtonPressed()
                            toggle.toggle()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24))
                                .foregroundColor(.accentColor)
                        }
                        .padding(.leading)
                        .offset(x: 0, y: 16)
                        Spacer()
                    }
                    
                    Text("domino")
                        .font(.custom("Montserrat-Medium", size: 27))
                        .foregroundColor(Color.accentColor)
                        .tracking(8)
                        .multilineTextAlignment(.center)
                }
                
                Text("rally")
                    .font(.custom("Montserrat-Medium", size: 17))
                    .padding(.bottom)
                    .tracking(4)

                if !clipsViewModel.errorText.isEmpty && clipsViewModel.clips.isEmpty {
                    Text(clipsViewModel.errorText)
                        .padding(.top)
                        .foregroundColor(Color(UIColor.systemGray))
                } else if clipsViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(.top)
                }
                
                ScrollView {
                    LazyVGrid(columns: [GridItem](repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                        ForEach(clipsViewModel.clips, id: \.self) { clip in
                            ClipView(clip: clip)
                        }
                        .frame(height: (192 / 108) * geometry.size.width / 3)
                    }
                    .padding(.leading, 4)
                    .padding(.trailing, 4)
                }
                .padding(.top, -16)
                .padding(.bottom, -12)
                
                ZStack {
                     Rectangle()
                        .frame(height: 40)
                        .foregroundColor(.accentColor)

                    Text("code: \(clipsViewModel.code)")
                        .font(.custom("Montserrat-Light", size: 20))
                        .foregroundColor(.accentColor)
                        .colorInvert()
                        .onTapGesture {
                            print("Code tapped")
                            UIPasteboard.general.string = clipsViewModel.code
                        }
                }
                
                Button(action: {
                    if clipsViewModel.buttonText == "place a domino" {
                        clipsViewModel.uploadButtonPressed()
                    } else if clipsViewModel.buttonText == "share this rally" {
                        clipsViewModel.shareButtonPressed()
                    }
                }) {
                    Text(clipsViewModel.buttonText)
                        .font(.custom("Montserrat-Light", size: 24, relativeTo: .title))
                        .foregroundColor(.accentColor)
                        .colorInvert()
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(50)
                }
                .opacity(clipsViewModel.uploadDisabled ? 0.5 : 1)
            }
            .onAppear {
                if code.isEmpty {
                    print("Entered ClipsView with empty code")
                    clipsViewModel.openImagePicker()
                } else {
                    clipsViewModel.enterCode(code: code)
                }
            }   
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
        private let password = "ThisIsEpicPassword"
        private lazy var imagePicker = ImagePicker(messenger: self)

        init() {
            print("Initializing ClipsViewModel")
        }
        
        private func clearStorage() {
            DispatchQueue.main.async {
                self.clips = []
            }
        }
        
        func openImagePicker() {
            self.imagePicker.open()
        }

        func enterCode(code: String) {
            if self.clips.isEmpty {
                print("Entered enterCode with code: \(code)")
                self.codeInternal = code
                self.code = code
                self.downloadExistingThing()
            } else {
                print("Ignoring enterCode because clips is not empty")
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

        private func handleError(errorCode: String, logMessage: String = "") {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorText = "Error Code \(errorCode)"
            }
            if !logMessage.isEmpty {
                print(logMessage)
            }
        }

        struct ClipMetaData: Codable {
            var code: String
            var id: String
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
            request.setValue(self.password, forHTTPHeaderField: "password")

            print("Starting GET request to \(String(describing: url))")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // data validation
                guard let data = data, error == nil else {
                    self.handleError(errorCode: "D1")
                    return
                }
                print("response = \(String(describing: response))")
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    self.handleError(errorCode: "D11-\(httpStatus.statusCode)")
                    return
                }

                // convert JSON
                print(data)
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
                    request.setValue(self.password, forHTTPHeaderField: "password")

                    print("Starting GET request to \(String(describing: url))")
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        // data validation
                        guard let data = data, error == nil else {
                            self.handleError(errorCode: "D3")
                            return
                        }
                        print("response = \(String(describing: response))")
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
                            print("response = \(String(describing: response))")
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
            request.setValue(self.password, forHTTPHeaderField: "password")
            request.setValue(fileExtension, forHTTPHeaderField: "file-extension")

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
                print("Response: \(String(describing: response))")
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
                        self.handleError(errorCode: "E51-\(httpStatus.statusCode)", logMessage: String(describing: response))
                        return
                    }
                    print("response = \(String(describing: response))")

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
            request.setValue(self.password, forHTTPHeaderField: "password")
            request.setValue(fileExtension, forHTTPHeaderField: "file-extension")

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
                print("Response: \(String(describing: response))")
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
                        self.handleError(errorCode: "E51-\(httpStatus.statusCode)", logMessage: String(describing: response))
                        return
                    }
                    print("response = \(String(describing: response))")

                    // reload everything
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

        // function that will calls an API and returns 
    }
}
