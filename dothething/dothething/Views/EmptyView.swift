//
//  EmptyView.swift
//  dothething
//
//  Created by Nathan Chan on 11/6/22.
//

import SwiftUI

struct EmptyView: View {
    @ObservedObject private(set) var emptyViewModel: EmptyViewModel
    @Binding var code: String
    @Binding var currentView: CurrentView

    var body: some View {
        HStack {
            Button(action: {
                currentView = .home
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
            }
            .padding(.leading)
            .offset(x: 0, y: 16)
            Spacer()
        }
        
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

struct EmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView(emptyViewModel: EmptyView.EmptyViewModel(), code: .constant(""), currentView: .constant(.empty))
    }
}

extension EmptyView {
    class EmptyViewModel: ObservableObject {
        
        init() {
            print("EmptyViewModel init")
        }
    }
}
