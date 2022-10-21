//
//  HomeView.swift
//  dothething
//
//  Created by Nathan Chan on 10/19/22.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private(set) var homeViewModel: HomeViewModel
    @Binding var code: String
    @Binding var toggle: Bool

    var body: some View {
        VStack {
            Image(systemName: "camera")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Do The Thing")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
            
            Spacer()

            HStack {
                TextField("Enter a code", text: $code)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        toggle.toggle()
                    }
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                Button(action: {
                    toggle.toggle()
                }) {
                    Text("Enter")
                }
            }

        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(homeViewModel: HomeView.HomeViewModel(), code: .constant(""), toggle: .constant(true))
    }
}

extension HomeView {
    class HomeViewModel: ObservableObject {
        init() {
            print("Initializimg HomeViewModel")
        }
    }
}
