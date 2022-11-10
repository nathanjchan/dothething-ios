//
//  EmptyView.swift
//  dothething
//
//  Created by Nathan Chan on 11/6/22.
//

import SwiftUI

struct UploadView: View {
    @ObservedObject private(set) var uploadViewModel: UploadViewModel
    @Binding var code: String
    @Binding var currentView: CurrentView

    var body: some View {
        VStack {
            Button(action: {
            }) {
                Text("start recording")
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
                currentView = .clips
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
        }
    }
}

struct EmptyView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView(uploadViewModel: UploadView.UploadViewModel(), code: .constant(""), currentView: .constant(.upload))
    }
}

extension UploadView {
    class UploadViewModel: ObservableObject {
        
        init() {
            print("UploadViewModel init")
        }
    }
}
