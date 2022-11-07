//
//  Networker.swift
//  dothething
//
//  Created by Nathan Chan on 11/5/22.
//

import Foundation

class Networker {
    static func checkIfUserUploadedToCode(code: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")
        request.setValue(GlobalConfig.shared.sessionId, forHTTPHeaderField: "session-id")
        request.setValue("zz", forHTTPHeaderField: "file-extension")
        request.setValue(code, forHTTPHeaderField: "code")
        let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let error = error {
                print("Error took place \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
                if response.statusCode == 409 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        task.resume()
    }
}
