//
//  ContentView.swift
//  dothething
//
//  Created by Nathan Chan on 10/20/22.
//

import SwiftUI

struct ContentView: View {
    @State var code: String = ""
    @State var showHome: Bool = true

    var body: some View {
        if showHome {
            HomeView(homeViewModel: HomeView.HomeViewModel(), code: $code, toggle: $showHome)
        } else {
            ClipsView(clipsViewModel: ClipsView.ClipsViewModel(), code: $code, toggle: $showHome)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
