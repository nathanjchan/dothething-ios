//
//  HomeView.swift
//  dothething
//
//  Created by Nathan Chan on 10/19/22.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Binding var code: String
    @Binding var currentView: CurrentView

    var body: some View {
        Text("Home: daily stats, recommended feed")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(code: .constant(""), currentView: .constant(.home))
            .environmentObject(HomeView.HomeViewModel())
    }
}

extension HomeView {
    class HomeViewModel: ObservableObject {
        init() {
            print("Initializing HomeViewModel")
        }
    }
}
