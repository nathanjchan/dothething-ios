//
//  SearchView.swift
//  dothething
//
//  Created by Nathan Chan on 11/9/22.
//

import SwiftUI

struct SearchView: View, KeyboardReadable {
    @StateObject var clipsViewModel = ClipsViewModel()
    @Binding var code: String
    @Binding var currentView: CurrentView
    @State private var isKeyboardVisible = false
    @State private var showClipsView = false
    
    var body: some View {
        NavigationStack {
            VStack {            
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
                            showClipsView = true
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
                
                HStack {
                    Spacer()
                    
                    if isKeyboardVisible {
                        Text("cancel")
                            .font(Font.custom("Montserrat-LightItalic", size: 18, relativeTo: .caption))
                            .onTapGesture {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                    } else {
                        Text("enter")
                        .font(Font.custom("Montserrat-LightItalic", size: 18, relativeTo: .caption))
                        .onTapGesture {
                            showClipsView = true
                        }
                    }
                }
                .frame(width: 250)
            }
            .navigationDestination(isPresented: $showClipsView) {
                ClipsView(code: $code, currentView: $currentView)
                    .environmentObject(clipsViewModel)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            VStack {
                                Text("domino")
                                    .font(.custom("Montserrat-Medium", size: 20))
                                    .foregroundColor(Color.accentColor)
                                    .tracking(8)
                                
                                Text("cascade")
                                    .font(.custom("Montserrat-Medium", size: 16))
                                    .foregroundColor(Color.accentColor)
                                    .tracking(4)
                            }
                            .offset(y: -4)
                        }
                    }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("domino")
                            .font(.custom("Montserrat-Medium", size: 20))
                            .foregroundColor(Color.accentColor)
                            .tracking(8)
                        
                        Text("search")
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundColor(Color.accentColor)
                            .tracking(4)
                    }
                    .offset(y: -4)
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(code: .constant(""), currentView: .constant(.search))
    }
}
