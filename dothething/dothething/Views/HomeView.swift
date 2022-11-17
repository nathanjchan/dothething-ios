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
        NavigationStack {
            Spacer()
            Text("nothing here yet...")
                .font(.custom("Montserrat-Italic", size: 24))
                .padding()
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("domino")
                        .font(.custom("Montserrat-Medium", size: 20))
                        .foregroundColor(Color.accentColor)
                        .tracking(8)
                    
                    Text("home")
                        .font(.custom("Montserrat-Medium", size: 16))
                        .foregroundColor(Color.accentColor)
                        .tracking(4)
                }
                .offset(x: 4, y: -4)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible)
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
