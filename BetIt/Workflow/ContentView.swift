//
//  ContentView.swift
//  BetIt
//
//  Created by Asim Brown on 5/29/21.
//

import SwiftUI
import AlertToast

struct ContentView: View {
    @EnvironmentObject private var user: UserModel
    @EnvironmentObject private var socket: SocketIOManager
    var body: some View {
        TabView {
            UpcomingGames()
                .tabItem {
                    Image(systemName: "house.fill")
                }
 
            AccountDetails()
                .tabItem {
                    Image(systemName: "person.fill")
                }

            CreateWager()
                .tabItem {
                    Image(systemName: "plus")
                }.foregroundColor(Color("Accent2"))

            WalletDetailsView()
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                }

            Text("The content of the fifth view")
                .tabItem {
                    Image(systemName: "percent")
                }
        }
        .toast(isPresenting: $socket.showToast, duration: 2, tapToDismiss: true) {
            AlertToast(displayMode: .hud, type: .complete(Color("Accent2")), title: socket.toastMessage)
        }
        .accentColor(Color("Accent2"))
        .onAppear(){
            socket.establishConnection(walletAddress: user.walletAddress)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
