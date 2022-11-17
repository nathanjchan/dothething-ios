//
//  UploadView.swift
//  dothething
//
//  Created by Nathan Chan on 11/6/22.
//

import SwiftUI

struct UploadView: View {
    @ObservedObject private(set) var uploadViewModel: UploadViewModel
    @StateObject var clipsViewModel = ClipsViewModel()
    @Binding var code: String
    @State private var showClipsView = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                ZStack {
                    Trapezoid()
                        .fill(Color.accentColor)
                        .frame(width: 341, height: 270)
                    
                    Staple()
                        .fill(Color.accentColor)
                        .frame(width: 171, height: 112)
                        .offset(x: 0, y: -100)
                    
                    Staple()
                        .fill(Color.accentColor)
                        .colorInvert()
                        .frame(width: 171, height: 112)
                        .offset(x: 0, y: -100)
                        .mask(Trapezoid().frame(width: 341, height: 270))
                    
                    Staple()
                        .fill(Color.accentColor)
                        .frame(width: 171, height: 112)
                        .rotationEffect(.degrees(180))
                        .offset(x: 0, y: 100)
                    
                    Staple()
                        .fill(Color.accentColor)
                        .colorInvert()
                        .frame(width: 171, height: 112)
                        .rotationEffect(.degrees(180))
                        .offset(x: 0, y: 100)
                        .mask(Trapezoid().frame(width: 341, height: 270))
                    
                    Text("no one is here yet... \nit's your time to shine!")
                        .font(.custom("Montserrat-Italic", size: 24))
                        .foregroundColor(.accentColor)
                        .colorInvert()
                        .multilineTextAlignment(.center)
                }

                Spacer()
                
                Button(action: {
                    uploadViewModel.openCamera()
                }) {
                    Text("record a video")
                        .font(.custom("Montserrat-Light", size: 24, relativeTo: .title))
                        .foregroundColor(.accentColor)
                        .colorInvert()
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(50)
                }

                Button(action: {
                    code = ""
                    showClipsView = true
                }) {
                    Text("upload from gallery")
                        .font(.custom("Montserrat-Light", size: 24, relativeTo: .title))
                        .foregroundColor(.accentColor)
                        .colorInvert()
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(50)
                }
                
                Spacer()
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
                    
                    Text("create")
                        .font(.custom("Montserrat-Medium", size: 16))
                        .foregroundColor(Color.accentColor)
                        .tracking(4)
                }
                .offset(x: 4, y: -4)
            }
        }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView(uploadViewModel: UploadView.UploadViewModel(), code: .constant(""))
    }
}

extension UploadView {
    class UploadViewModel: ObservableObject, ImagePickerMessenger {
        private lazy var cameraOpener = CameraOpener(messenger: self)
        
        init() {
            print("Intializing UploadViewModel")
        }

        func openCamera() {
            print("Entered UploadViewModel.openCamera")
            cameraOpener.open()
        }
        
        func upload(videoUrl: URL) {
            // check if video can be saved to photo library
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoUrl.path) {
                // save video to photo library
                print("Saving video to photo library")
                UISaveVideoAtPathToSavedPhotosAlbum(videoUrl.path, nil, nil, nil)
            }
        }
        
        func cancel() {
            // do nothing
        }
    }
}
