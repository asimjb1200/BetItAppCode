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
    private var userService: UserNetworking = .shared
    @State var isLoading = true
    
    init() {
    }
    
    
    var body: some Scene {
        WindowGroup {
            if user.isLoggedIn == true {
                ContentView()
                    .environmentObject(user)
                    .environmentObject(socket)
            } else {
                if self.isLoading {
                    Text("Loading...")
                    .onAppear(){
                        if user.isLoggedIn == false {
                            self.startUpStuff()
                        }
                    }
                } else {
                    LoginView()
                        .environmentObject(user)
                }
            }
        }
    }
}

extension BetItApp {
    func startUpStuff() {
        // check for a user in user defaults storage
        let storedUser = userService.loadUserFromDevice()
        if storedUser != nil {
            user.username = storedUser!.username
            user.walletAddress = storedUser!.walletAddress
            
            // now search for the user's access token from the keychain
            let storedAccessToken = userService.loadAccessToken()
            guard let storedAccessToken = storedAccessToken else {
                return
            }
            user.accessToken = storedAccessToken
            user.isLoggedIn = true
            self.isLoading = false
        } else {
            // user.isLoggedIn = false
            self.isLoading = false
        }
    }
}
