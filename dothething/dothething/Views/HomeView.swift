//
//  HomeView.swift
//  dothething
//
//  Created by Nathan Chan on 10/19/22.
//

import SwiftUI

struct HomeView: View, KeyboardReadable {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @ObservedObject private(set) var homeViewModel: HomeViewModel
    @Binding var code: String
    @Binding var currentView: CurrentView
    @State private var isKeyboardVisible: Bool = false

    var body: some View {
        VStack {
            
            Spacer()

            Button(action: {
                print("Profile button tapped")
                currentView = .profile
            }) {
                Text("profile")
            }
                        
            Button(action: {
                code = ""
                currentView = .empty
            }) {
                Text("start a rally")
                    .font(.custom("Montserrat-Light", size: 24, relativeTo: .title))
                    .foregroundColor(.accentColor)
                    .colorInvert()
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(50)
            }
            .opacity(isKeyboardVisible ? 0 : 1)
            .padding(.bottom, 8)
            
            Text("join an existing rally:")
                .font(Font.custom("Montserrat-LightItalic", size: 18, relativeTo: .caption))
            
            TextField("enter rally code", text: $code)
                .font(Font.custom("Montserrat-Light", size: 24, relativeTo: .title))
                .cornerRadius(50)
                .frame(width: 300, height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.accentColor, lineWidth: 4)
                )
                .multilineTextAlignment(.center)
                .onSubmit {
                    if code.count == 7 || code == "dothethingtest" {
                        currentView = .clips
                    }
                }
                .keyboardType(.alphabet)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onReceive(keyboardPublisher) { newIsKeyboardVisible in
                    isKeyboardVisible = newIsKeyboardVisible
                }
            
            Text("cancel")
                .font(Font.custom("Montserrat-LightItalic", size: 18, relativeTo: .caption))
                .opacity(isKeyboardVisible ? 1 : 0)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .padding(.bottom, isKeyboardVisible ? 250 : 100)
                .offset(x: 100)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(homeViewModel: HomeView.HomeViewModel(), code: .constant(""), currentView: .constant(.home))
    }
}

extension HomeView {
    class HomeViewModel: ObservableObject {
        init() {
            print("Initializing HomeViewModel")
        }
    }
}
