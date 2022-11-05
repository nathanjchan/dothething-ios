//
//  ContentView.swift
//  dothething
//
//  Created by Nathan Chan on 10/20/22.
//

import SwiftUI
import GoogleSignIn

enum CurrentView {
    case home
    case clips
    case profile
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var code: String = ""
    @State var currentView: CurrentView = .home

    var body: some View {
        if authViewModel.isSignedIn {
            switch currentView {
            case .home:
                HomeView(homeViewModel: HomeView.HomeViewModel(), code: $code, currentView: $currentView)
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut)
                    .transition(.move(edge: .trailing))
            case .clips:
                ClipsView(clipsViewModel: ClipsViewModel(), code: $code, currentView: $currentView)
                    .transition(.move(edge: .trailing))
                    .animation(.easeInOut)
                    .transition(.move(edge: .leading))
            case .profile:
                ProfileView(profileViewModel: ProfileView.ProfileViewModel(), currentView: $currentView)
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
                            GlobalConfig.shared.googleUser = user
                            GlobalConfig.shared.name = user.profile?.givenName
                            GlobalConfig.shared.profilePicture = user.profile?.imageURL(withDimension: 320)
                            print("Restored sign in with Google: \(GlobalConfig.shared.name ?? "no name")")

                            user.authentication.do { authentication, error in
                                guard error == nil else { return }
                                guard let authentication = authentication else { return }
                                guard let idToken = authentication.idToken else { return }
                                authViewModel.tokenSignInExample(idToken: idToken)
                            }
                        }
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