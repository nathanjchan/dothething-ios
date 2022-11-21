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
    case upload
    case search
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject var homeViewModel = HomeView.HomeViewModel()
    @StateObject var profileViewModel = ProfileView.ProfileViewModel()
    @StateObject var searchViewModel = SearchView.SearchViewModel()
    @State var code: String = ""
    @State var currentView: CurrentView = .home

    var body: some View {
        NavigationStack {
            VStack {
                SignInView()
                    .onAppear {
                        currentView = .home
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
                        DispatchQueue.main.async {
                            authViewModel.isLoading = true
                        }
                        GIDSignIn.sharedInstance.handle(url)
                        DispatchQueue.main.async {
                            authViewModel.isLoading = false
                        }
                    }
            }
            .navigationDestination(isPresented: $authViewModel.isSignedIn) {
                VStack {
                    if currentView == .home {
                        HomeView(currentView: $currentView)
                            .navigationBarBackButtonHidden(true)
                            .environmentObject(homeViewModel)
                    } else if currentView == .search {
                        SearchView(code: $code)
                            .navigationBarBackButtonHidden(true)
                            .environmentObject(searchViewModel)
                    } else if currentView == .upload {
                        UploadView(uploadViewModel: UploadView.UploadViewModel(), code: $code)
                            .navigationBarBackButtonHidden(true)
                    } else if currentView == .profile {
                        ProfileView()
                            .navigationBarBackButtonHidden(true)
                            .environmentObject(profileViewModel)
                    }

                    Spacer()
                    
                    BottomBarView(currentView: $currentView)
                        .padding(.top, 4)
                        .padding(.bottom, 4)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
    }
}
