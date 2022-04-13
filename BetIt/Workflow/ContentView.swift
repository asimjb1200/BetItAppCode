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

            PriceDataView()
                .tabItem {
                    Image("stock-exchange-app")
                        .renderingMode(.template)
                        .foregroundColor(Color("Accent2"))
                }
        }
        .toast(isPresenting: $socket.showToast, duration: 2, tapToDismiss: true) {
            AlertToast(displayMode: .hud, type: .complete(Color("Accent2")), title: socket.toastMessage)
        }
        .accentColor(Color("Accent2"))
        .onAppear(){
            socket.establishConnection(walletAddress: user.walletAddress)
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
             print("Moving to the background!")
            // disconnect their socket
            socket.closeConnection(walletAddress: user.walletAddress)
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            print("Moving back to the foreground!")
            // reconnect the user's socket
            socket.establishConnection(walletAddress: user.walletAddress)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
