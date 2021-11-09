//
//  BetItApp.swift
//  BetIt
//
//  Created by Asim Brown on 5/29/21.
//

import SwiftUI

@main
struct BetItApp: App {
    @StateObject var user: UserModel = UserModel.buildUser(username: "", access_token: "", refresh_token: "", wallet_address: "", exp: 0, isLoggedIn: false)
    @StateObject var socket: SocketIOManager = .sharedInstance
    
    var body: some Scene {
        WindowGroup {
            if user.isLoggedIn == true {
                ContentView()
                    .environmentObject(user)
                    .environmentObject(socket)
            } else {
                LoginView()
                    .environmentObject(user)
            }
        }
    }
}
