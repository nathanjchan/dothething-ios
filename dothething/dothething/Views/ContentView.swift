//
//  ContentView.swift
//  dothething
//
//  Created by Nathan Chan on 10/20/22.
//

import SwiftUI

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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
