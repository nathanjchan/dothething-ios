//
//  ContentView.swift
//  dothething
//
//  Created by Nathan Chan on 10/20/22.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var code: String = ""
    @State var showHome: Bool = true

    var body: some View {
        if authViewModel.isSignedIn {
            if showHome {
                HomeView(homeViewModel: HomeView.HomeViewModel(), code: $code, toggle: $showHome)
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut)
                    .transition(.move(edge: .trailing))
            } else {
                ClipsView(clipsViewModel: ClipsView.ClipsViewModel(), code: $code, toggle: $showHome)
                    .transition(.move(edge: .trailing))
                    .animation(.easeInOut)
                    .transition(.move(edge: .leading))
            }
        } else {
            SignInView()
                .transition(.move(edge: .trailing))
                .animation(.easeInOut)
                .transition(.move(edge: .leading))
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
                        authViewModel.isLoading = false
                    }
                }
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
