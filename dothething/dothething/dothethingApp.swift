//
//  dothethingApp.swift
//  dothething
//
//  Created by Nathan Chan on 10/19/22.
//

import SwiftUI
import GoogleSignIn

@main
struct dothethingApp: App {
    @StateObject var authViewModel = AuthenticationViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            guard let user = user else { return }
                            authViewModel.isSignedIn = true
                            GlobalConfig.shared.googleUser = user
                            GlobalConfig.shared.name = user.profile?.givenName
                            GlobalConfig.shared.profilePicture = user.profile?.imageURL(withDimension: 320)
                            print("Restored sign in with Google: \(GlobalConfig.shared.name ?? "no name")")
                        }
                    }
                }
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
