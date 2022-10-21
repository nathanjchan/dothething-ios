//
//  ContentView.swift
//  dothething
//
//  Created by Nathan Chan on 10/20/22.
//

import SwiftUI

struct ContentView: View {
    @State var code: String = ""
    @State var toggle: Bool = true

    var body: some View {
        if toggle {
            HomeView(homeViewModel: HomeView.HomeViewModel(), code: $code, toggle: $toggle)
        } else {
            ClipsView(clipsViewModel: ClipsView.ClipsViewModel(), code: $code, toggle: $toggle)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
