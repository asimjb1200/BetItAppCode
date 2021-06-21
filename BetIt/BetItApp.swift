//
//  BetItApp.swift
//  BetIt
//
//  Created by Asim Brown on 5/29/21.
//

import SwiftUI

@main
struct BetItApp: App {
    @StateObject var user: User = .shared
    
    var body: some Scene {
        WindowGroup {
            if user.isLoggedIn {
                ContentView().environmentObject(user)
            } else {
                LoginView().environmentObject(user)
                    .onAppear(){
                        SocketIOManager.sharedInstance.establishConnection()
                    }
            }
        }
    }
}
