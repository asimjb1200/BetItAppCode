//
//  BetItApp.swift
//  BetIt
//
//  Created by Asim Brown on 5/29/21.
//

import SwiftUI

@main
struct BetItApp: App {
    @StateObject var userManager: UserManager = UserManager.shared
    
    var body: some Scene {
        WindowGroup {
            if userManager.user.isLoggedIn {
                ContentView()
                    .environmentObject(userManager)
            } else {
                LoginView()
                    .environmentObject(userManager)
                    .onAppear(){
                        SocketIOManager.sharedInstance.establishConnection()
                    }
            }
        }
    }
}
