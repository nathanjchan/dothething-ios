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
                    .font(Font.custom("Montserrat-LightItalic", size: 18, relativeTo: .caption))
                    .padding(.top, 8)
                
                HStack {
                    Image(systemName: "xmark")
                        .font(Font.custom("Montserrat-Light", size: 18, relativeTo: .caption))
                        .foregroundColor(Color.accentColor)
                        .padding(.leading, 16)
                        .onTapGesture {
                            self.code = ""
                        }
                    
                    TextField("enter cascade code", text: $code)
                        .font(Font.custom("Montserrat-Light", size: 24, relativeTo: .title))
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
                        .font(Font.custom("Montserrat-Light", size: 18, relativeTo: .caption))
                        .foregroundColor(Color.accentColor)
                        .padding(.trailing, 16)
                        .onTapGesture {
                            if code.count == 7 || code == "dothethingtest" {
                                showClipsView = true
                                searchViewModel.saveCode(code: code)
                            }
                        }
                }
                .padding(.bottom, 16)

                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(searchViewModel.codes, id: \.self) { code in
                        HStack {
                            Spacer()
                            
                            Text(code)
                                .font(Font.custom("Montserrat-Light", size: 18, relativeTo: .caption))
                                .foregroundColor(Color.accentColor)
                                                    
                            Image(systemName: "chevron.right")
                                .font(Font.custom("Montserrat-Light", size: 18, relativeTo: .caption))
                                .foregroundColor(Color.accentColor)
                        }
                        .onTapGesture {
                            self.code = code
                            showClipsView = true
                        }
                        .padding(.bottom, 4)
                        .padding(.trailing, 16)
                    }
                }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
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
        @Published var codes: [String] = ["yee", "haw"]

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
            if let index = codes.firstIndex(of: code) {
                codes.remove(at: index)
            }
            codes.insert(code, at: 0)

            // save the array to user defaults
            UserDefaults.standard.set(codes, forKey: "codes")
        }
    }
}
