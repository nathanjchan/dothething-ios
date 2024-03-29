//
//  Networker.swift
//  dothething
//
//  Created by Nathan Chan on 11/5/22.
//

import Foundation
import SwiftUI

class Networker {
    static func checkIfUserUploadedToCode(code: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        request.setValue(code, forHTTPHeaderField: "code")
        request.setValue("zz", forHTTPHeaderField: "file-extension")
        request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")
        request.setValue(GlobalConfig.shared.sessionId, forHTTPHeaderField: "session-id")
        let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let error = error {
                print("\(#function) Error took place \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("\(#function) Response HTTP Status code: \(response.statusCode)")
                if response.statusCode == 409 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        task.resume()
    }

    static func downloadProfileClips(batchIndex: Int, completion: @escaping ([ClipMetadata]) -> Void) {
        let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.setValue(String(batchIndex), forHTTPHeaderField: "batch-index")
        request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")
        request.setValue(GlobalConfig.shared.sessionId, forHTTPHeaderField: "session-id")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("\(#function) Error took place \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("\(#function) Response HTTP Status code: \(response.statusCode)")
                if response.statusCode == 200 {
                    if let data = data {
                        let decoder = JSONDecoder()
                        guard let dataArray = try? decoder.decode([ClipMetadata].self, from: data) else {
                            fatalError("\(#function) Failed to decode JSON")
                        }
                        completion(dataArray)
                    }
                }
            }
        }
        task.resume()
    }

    static func downloadExistingThing(code: String, batchIndex: Int, completion: @escaping ([ClipMetadata]) -> Void) {
        let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething")
        guard let url = url else { fatalError() }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(code, forHTTPHeaderField: "code")
        request.setValue(String(batchIndex), forHTTPHeaderField: "batch-index")
        request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("\(#function) Error took place \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("\(#function) Response HTTP Status code: \(response.statusCode)")
                if response.statusCode == 200 {
                    if let data = data {
                        let decoder = JSONDecoder()
                        guard let dataArray = try? decoder.decode([ClipMetadata].self, from: data) else {
                            fatalError("\(#function) Failed to decode JSON")
                        }
                        completion(dataArray)
                    }
                }
            }
        }
        task.resume()
    }

    static func downloadThumbnail(urlString: String, completion: @escaping (UIImage) -> Void) {
        let url = URL(string: urlString)
        guard let url = url else { fatalError() }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                completion(UIImage(data: data) ?? UIImage())
            }
        }
        task.resume()
    }

    static func downloadVideo(id: String, completion: @escaping (Data) -> Void) {
        let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething")
        guard let url = url else { fatalError() }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(id, forHTTPHeaderField: "id")
        request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("\(#function) Error took place \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("\(#function) Response HTTP Status code: \(response.statusCode)")
                if response.statusCode == 200 {
                    if let data = data {
                        let preUrlString = String(data: data, encoding: .utf8)
                        guard let preUrlString = preUrlString else { fatalError() }
                        let preUrl = URL(string: preUrlString)
                        guard let preUrl = preUrl else { fatalError() }
                        let task = URLSession.shared.dataTask(with: preUrl) { (data, response, error) in
                            if let error = error {
                                print("\(#function) Error took place \(error)")
                                return
                            }
                            if let response = response as? HTTPURLResponse {
                                print("\(#function) Response HTTP Status code: \(response.statusCode)")
                                if response.statusCode == 200 {
                                    if let data = data {
                                        completion(data)
                                    }
                                }
                            }
                        }
                        task.resume()
                    }
                }
            }
        }
        task.resume()
    }

    static func getHomeFeed(batchIndex: Int, completion: @escaping ([ClipMetadata]) -> Void) {
        let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/homefeed")
        guard let url = url else { fatalError() }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(String(batchIndex), forHTTPHeaderField: "batch-index")
        request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")
        request.setValue(GlobalConfig.shared.sessionId, forHTTPHeaderField: "session-id")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("\(#function) Error took place \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("\(#function) Response HTTP Status code: \(response.statusCode)")
                if response.statusCode == 200 {
                    if let data = data {
                        let decoder = JSONDecoder()
                        guard let dataArray = try? decoder.decode([ClipMetadata].self, from: data) else {
                            fatalError("\(#function) Failed to decode JSON")
                        }
                        completion(dataArray)
                    }
                }
            }
        }
        task.resume()
    }
    
    static func getInteractions(completion: @escaping (Int) -> Void) {
        let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/homefeed")
        guard let url = url else { fatalError() }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")
        request.setValue(GlobalConfig.shared.sessionId, forHTTPHeaderField: "session-id")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("\(#function) Error took place \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("\(#function) Response HTTP Status code: \(response.statusCode)")
                if response.statusCode == 200 {
                    if let data = data {
                        let decoder = JSONDecoder()
                        guard let interactions = try? decoder.decode(String.self, from: data) else {
                            fatalError("\(#function) Failed to decode JSON")
                        }
                        completion(Int(interactions) ?? 0)
                    }
                }
            }
        }
        task.resume()
    }
    
    static func getShareMessage(code: String, completion: @escaping (String) -> Void) {
        let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething")
        guard let url = url else { fatalError() }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(code, forHTTPHeaderField: "code")
        request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("\(#function) Error took place \(error)")
                completion("")
            }
            if let response = response as? HTTPURLResponse {
                print("\(#function) Response HTTP Status code: \(response.statusCode)")
                if response.statusCode == 200 {
                    if let data = data {
                        let decoder = JSONDecoder()
                        guard let message = try? decoder.decode(String.self, from: data) else {
                            fatalError("\(#function) Failed to decode JSON")
                        }
                        completion(message)
                    }
                }
            }
            completion("")
        }
        task.resume()
    }

    static func downloadProfilePicture(url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else { fatalError() }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                completion(UIImage(data: data))
            }
        }
        task.resume()
    }

    static func isSessionIdValid(completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/dothething")
        guard let url = url else { fatalError() }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(GlobalConfig.shared.sessionId, forHTTPHeaderField: "session-id")
        request.setValue(GlobalConfig.shared.password, forHTTPHeaderField: "password")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("\(#function) Error took place \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("\(#function) Response HTTP Status code: \(response.statusCode)")
                if response.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        task.resume()
    }
}
