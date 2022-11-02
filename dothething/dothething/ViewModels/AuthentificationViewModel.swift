//
//  AuthentificationViewModel.swift
//  dothething
//
//  Created by Nathan Chan on 10/31/22.
//

import GoogleSignIn

class AuthenticationViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var isLoading: Bool = false

    func tokenSignInExample(idToken: String) {
        self.isLoading = true
        guard let authData = try? JSONEncoder().encode(["idToken": idToken]) else { return }
        let url = URL(string: "https://kenv1ez376.execute-api.us-west-1.amazonaws.com/alpha/googletokensignin")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.uploadTask(with: request, from: authData) { data, response, error in
            if let data = data {
                let dataString = String(data: data, encoding: .utf8)
                print(dataString ?? "no data")
            }
            print("\(String(describing: response))")
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("Logged in successfully")
                    DispatchQueue.main.async {
                        self.isSignedIn = true
                        self.isLoading = false
                    }
                }
            }
        }
        task.resume()
    }
    
    func handleSignInButton() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        guard let rootViewController = window?.rootViewController else {
            print("No root view controller")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(
            with: GlobalConfig.shared.signInConfig,
            presenting: rootViewController) { user, error in
                guard error == nil else { return }
                guard let user = user else { return }
                GlobalConfig.shared.googleUser = user
                GlobalConfig.shared.name = user.profile?.givenName
                GlobalConfig.shared.profilePicture = user.profile?.imageURL(withDimension: 320)
                print("Successfully signed in with Google: \(GlobalConfig.shared.name ?? "no name")")
                
                user.authentication.do { authentication, error in
                    guard error == nil else { return }
                    guard let authentication = authentication else { return }
                    guard let idToken = authentication.idToken else { return }
                    self.tokenSignInExample(idToken: idToken)
                }
            }
    }

    func handleSignOutButton() {
        GIDSignIn.sharedInstance.signOut()
        self.isSignedIn = false
        print("Successfully signed out")
    }
}
