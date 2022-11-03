//
//  dothethingApp.swift
//  dothething
//
//  Created by Nathan Chan on 10/19/22.
//

import SwiftUI

@main
struct dothethingApp: App {
    @StateObject var authViewModel = AuthenticationViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
