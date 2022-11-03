//
//  SignInView.swift
//  dothething
//
//  Created by Nathan Chan on 10/30/22.
//

import SwiftUI
import GoogleSignInSwift

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        GoogleSignInButton(action: authViewModel.handleSignInButton)
            .padding()
            .frame(width: 300)
            .disabled(authViewModel.isLoading)

        if authViewModel.isLoading {
            ProgressView()
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
