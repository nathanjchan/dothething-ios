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
        VStack {
            ZStack {
                Trapezoid()
                    .fill(Color.accentColor)
                    .frame(width: 341, height: 270)
                
                Staple()
                    .fill(Color.accentColor)
                    .frame(width: 171, height: 112)
                    .offset(x: 0, y: -100)
                
                Staple()
                    .fill(Color.accentColor)
                    .colorInvert()
                    .frame(width: 171, height: 112)
                    .offset(x: 0, y: -100)
                    .mask(Trapezoid().frame(width: 341, height: 270))
                
                Staple()
                    .fill(Color.accentColor)
                    .frame(width: 171, height: 112)
                    .rotationEffect(.degrees(180))
                    .offset(x: 0, y: 100)
                
                Staple()
                    .fill(Color.accentColor)
                    .colorInvert()
                    .frame(width: 171, height: 112)
                    .rotationEffect(.degrees(180))
                    .offset(x: 0, y: 100)
                    .mask(Trapezoid().frame(width: 341, height: 270))
                
                Text("domino")
                    .font(.custom("Montserrat-Medium", size: 56, relativeTo: .title))
                    .foregroundColor(.accentColor)
                    .colorInvert()
                    .tracking(16)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 100)
            .padding(.bottom, 50)
            
            Spacer()
            
            GoogleSignInButton(action: authViewModel.handleSignInButton)
                .padding()
                .frame(width: 300)
                .disabled(authViewModel.isLoading)

            ProgressView()
                .opacity(authViewModel.isLoading ? 1 : 0)
                .padding(.bottom, 100)
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthenticationViewModel())
    }
}
