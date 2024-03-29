//
//  SearchView.swift
//  dothething
//
//  Created by Nathan Chan on 11/9/22.
//

import SwiftUI

struct SearchView: View, KeyboardReadable {
    @EnvironmentObject var searchViewModel: SearchViewModel
    @StateObject var clipsViewModel = ClipsViewModel()
    @Binding var code: String
    @State private var isKeyboardVisible = false
    @State private var showClipsView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("join an existing cascade:")
                    .font(Font.custom("Montserrat-LightItalic", size: 18))
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                
                HStack {
                    Image(systemName: "xmark")
                        .font(Font.custom("Montserrat-Light", size: 18))
                        .foregroundColor(Color.accentColor)
                        .padding(.leading, 16)
                        .onTapGesture {
                            self.code = ""
                        }
                    
                    TextField("enter cascade code", text: $code)
                        .font(Font.custom("Montserrat-Medium", size: 24))
                        .cornerRadius(50)
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.accentColor, lineWidth: 4)
                        )
                        .multilineTextAlignment(.center)
                        .onSubmit {
                            if code.count == 8 || code == "dothethingtest" {
                                showClipsView = true
                                searchViewModel.saveCode(code: code)
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
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                    
                    Image(systemName: "chevron.right")
                        .font(Font.custom("Montserrat-Light", size: 18))
                        .foregroundColor(Color.accentColor)
                        .padding(.trailing, 16)
                        .onTapGesture {
                            if code.count == 8 || code == "dothethingtest" {
                                showClipsView = true
                                searchViewModel.saveCode(code: code)
                            }
                        }
                }
                .padding(.bottom, 16)

                if searchViewModel.codes.isEmpty {
                    Rectangle()
                        .colorInvert()
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                }
                
                Text("previous searches:")
                    .font(Font.custom("Montserrat-LightItalic", size: 18))
                    .padding(.bottom, -1)
                    .opacity(searchViewModel.codes.isEmpty ? 0 : 1)

                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(searchViewModel.codes, id: \.self) { code in
                        HStack {
                            Image(systemName: "xmark")
                                .font(Font.custom("Montserrat-Light", size: 18))
                                .foregroundColor(Color.accentColor)
                                .padding(.leading, 16)
                                .onTapGesture {
                                    searchViewModel.deleteCode(code: code)
                                }
                            Spacer()
                            Text(code)
                                .font(Font.custom("Montserrat-Medium", size: 18))
                                .foregroundColor(Color.accentColor)
                                .padding(.bottom, 2)
                            Image(systemName: "chevron.right")
                                .font(Font.custom("Montserrat-Light", size: 18))
                                .padding(.trailing, 16)
                        }
                        .onTapGesture {
                            self.code = code
                            showClipsView = true
                        }
                    }
                    .padding(.top, 16)
                }
                .border(Color.accentColor, width: 4)
                .padding(.bottom, 8)
                .padding(.horizontal, 16)
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationDestination(isPresented: $showClipsView) {
                ClipsView(code: $code)
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
                            .offset(x: 4, y: -4)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                clipsViewModel.refresh()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(Font.custom("Montserrat-Light", size: 16))
                                    .foregroundColor(Color.accentColor)
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.visible)
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
                    .offset(x: 4, y: -4)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(code: .constant(""))
            .environmentObject(SearchView.SearchViewModel())
    }
}

extension SearchView {
    class SearchViewModel: ObservableObject {
        @Published var codes: [String] = []

        init() {
            print("Initializing SearchViewModel")
            
            let defaults = UserDefaults.standard
            if let codes = defaults.stringArray(forKey: "codes") {
                self.codes = codes
            }
        }

        func saveCode(code: String) {
            print("Saving code: \(code)")
            // delete code if it already exists and add it to the front of the array
            codes.removeAll(where: { $0 == code })
            codes.insert(code, at: 0)

            // save the array to user defaults
            UserDefaults.standard.set(codes, forKey: "codes")
        }

        func deleteCode(code: String) {
            print("Deleting code: \(code)")
            if let index = codes.firstIndex(of: code) {
                codes.remove(at: index)
            }

            // save the array to user defaults
            UserDefaults.standard.set(codes, forKey: "codes")
        }
    }
}
