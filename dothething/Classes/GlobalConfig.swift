//
//  Settings.swift
//  dothething
//
//  Created by Nathan Chan on 10/30/22.
//

import Foundation
import GoogleSignIn

class GlobalConfig {
    static let shared = GlobalConfig()
    var signInConfig: GIDConfiguration
    var googleUser: GIDGoogleUser?
    var name: String?
    var profilePicture: UIImage?
    var sessionId: String?
    let password = "ThisIsEpicPassword"

    private init() {
        self.signInConfig = GIDConfiguration(clientID: "650326163788-rdn53s1u400dlf9iu0rh82371qnmenvh.apps.googleusercontent.com", serverClientID: "650326163788-pp25kvcqogpssfp108bln1pnhrunhju8.apps.googleusercontent.com")
    }
}
