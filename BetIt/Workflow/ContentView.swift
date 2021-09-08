//
//  ContentView.swift
//  BetIt
//
//  Created by Asim Brown on 5/29/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var user: UserModel
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
        .accentColor(Color("Accent2"))
        .onAppear(){
            SocketIOManager.sharedInstance.establishConnection(walletAddress: user.walletAddress)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
