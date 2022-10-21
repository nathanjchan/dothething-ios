//
//  HomeView.swift
//  dothething
//
//  Created by Nathan Chan on 10/20/22.
//

import SwiftUI

struct ClipsView: View {
    @ObservedObject private(set) var clipsViewModel: ClipsViewModel
    @Binding var code: String
    @Binding var toggle: Bool
    
    var body: some View {
        VStack {
            Text("The Thing")
                .font(.title)
            
            HStack {
                // back button
                Button(action: {
                    print("Back button tapped")
                    toggle.toggle()
                }) {
                    Text("Back")
                }
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // upload button
                Button(action: {
                    print("Upload button tapped")
                }) {
                    Text("Upload")
                }
                // put button on the top right side
                .padding(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Text("Code: \(code)")
            
            ScrollView {
                
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

extension ClipsView {
    class ClipsViewModel: ObservableObject {
        
        init() {
            print("Initializing ClipsViewModel")
        }

        func enterCode(code: String) {
            print("Entered enterCode with code: \(code)")
            self.upload(code: code)
        }

        func upload(code: String) {
            print("Entered upload with code: \(code)")

            // GET request to get presigned URL
            let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(code, forHTTPHeaderField: "code")

            print("Starting GET request to \(String(describing: url))")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // data validation
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    return
                }
                let responseString = String(data: data, encoding: .utf8)
                print("response = \(String(describing: response))")
                print("responseString = \(String(describing: responseString))")

                let presignedUrl = responseString
                let url = URL(string: presignedUrl ?? "")
                let request = URLRequest(url: url ?? URL(fileURLWithPath: ""))

                print("Starting GET request to \(String(describing: url))")
                let presignedTask = URLSession.shared.dataTask(with: request) { downData, downResponse, downError in
                    // data validation
                    guard let downData = downData, downError == nil else {
                        print("error=\(String(describing: downError))")
                        return
                    }
                    if let httpStatus = downResponse as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        return
                    }
                    let downResponseString = String(data: downData, encoding: .utf8)
                    print("response = \(String(describing: downResponse))")
                    print("responseString = \(String(describing: downResponseString))")

                    
                }
                presignedTask.resume()
            }
            task.resume()
        }
    }
}
