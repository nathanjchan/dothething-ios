//
//  BottomBarView.swift
//  dothething
//
//  Created by Nathan Chan on 11/10/22.
//

import SwiftUI

struct BottomBarView: View {
    @Binding var currentView: CurrentView
    
    var body: some View {
        HStack {
            Button(action: {
                currentView = .home
            }) {
                Image(systemName: "house")
                    .font(.system(size: 22))
                    .foregroundColor(currentView == .home ? .accentColor : .gray)
            }
            
            Spacer()
            
            Button(action: {
                currentView = .search
            }) {
                Image(systemName: "person.2.crop.square.stack")
                    .font(.system(size: 22))
                    .foregroundColor(currentView == .search ? .accentColor : .gray)
            }

            Spacer()

            Button(action: {
                currentView = .upload
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 22))
                    .foregroundColor(currentView == .upload ? .accentColor : .gray)
            }

            Spacer()
            
            Button(action: {
                currentView = .profile
            }) {
                Image(systemName: "person")
                    .font(.system(size: 22))
                    .foregroundColor(currentView == .profile ? .accentColor : .gray)
            }
        }
        .padding(.horizontal, 48)
    }
}

struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView(currentView: .constant(.home))
    }
}
