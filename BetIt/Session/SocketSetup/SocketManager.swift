//
//  SocketManager.swift
//  BetIt
//
//  Created by Asim Brown on 6/21/21.
//

import Foundation
import SocketIO

final class SocketIOManager: ObservableObject {
    static let sharedInstance = SocketIOManager()
    var manager = SocketManager(socketURL: URL(string:"ws://localhost:3000")!, config: [.log(true), .compress])
    var socket: SocketIOClient!
    
    init() {
        socket = manager.defaultSocket
        socket.on(clientEvent: .connect) {data, ack in
            
            print("socket connected")
        }
    }
    
    //Function to establish the socket connection with your server. Generally you want to call this method from your `Appdelegate` in the `applicationDidBecomeActive` method.
    func establishConnection(walletAddress: String) {

        // send the wallet address to the server to be used as the socket's key
        manager.defaultSocket.connect(withPayload: ["walletAddress": walletAddress])
    }

    //Function to close established socket connection. Call this method from `applicationDidEnterBackground` in your `Appdelegate` method.
    func closeConnection(walletAddress: String) {
        manager.defaultSocket.emit("disconnect me", walletAddress) // use this way to send msgs until I find out why the socket var doesn't work (below)
        manager.defaultSocket.disconnect()
        print("Disconnected from Socket !")
    }
    
    func notificationsOnlyForMe() {
        manager.defaultSocket.on("wallet txs") { data, ack in
            do {
                let noti = try JSONSerialization.data(withJSONObject: data[0])
                let decoded = try JSONDecoder().decode(Msg.self, from: noti)
                
            } catch let err {
                print(err.localizedDescription)
            }
        }
    }
    
    func getUpdatedWagers(completionHandler: @escaping (Result<WagerModel, Error>) -> ()) {
        manager.defaultSocket.on("wager updated") { data, ack in
            do {
                guard let dict = data[0] as? [String: Any] else { return }
                let wagerData = try JSONSerialization.data(withJSONObject: dict["wager"] as Any, options: [])
                let decoded = try JSONDecoder().decode(WagerModel.self, from: wagerData)
                completionHandler(.success(decoded))
            } catch let err {
                print(err)
            }
        }
    }
    
    func notifyWagerWinner(completionHandler: @escaping (Result<WagerWinner, Error>) -> ()) {
        manager.defaultSocket.on("payout started") { data, ack in
            do {
                guard let  dict = data[0] as? [String: Any] else { return }
                let winningAddress = try JSONSerialization.data(withJSONObject: dict["winner"] as Any, options: [])
                let decoded = try JSONDecoder().decode(WagerWinner.self, from: winningAddress)
                completionHandler(.success(decoded))
            } catch let err {
                print(err)
            }
        }
    }
}

struct WagerWinner: Decodable {
    var winner: String
}

class Msg: Decodable {
    var msg: String
    var detials: String
    var escrowWallet: String
}
