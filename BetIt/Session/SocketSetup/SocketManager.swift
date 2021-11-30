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
    var manager = SocketManager(socketURL: URL(string:"https://bet-it-casino.com/socket.io")!, config: [.log(true), .compress])
    var socket: SocketIOClient!
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    
    init() {
        socket = manager.defaultSocket
        socket.on(clientEvent: .connect) {data, ack in
            
            print("socket connected")
        }
        
        socket.on("test run") { data, ack in
            guard let msg = data[0] as? String else { return }
            self.toastMessage = msg
            self.showToast.toggle()
        }
        
        socket.on("game starting") { data, ack in
            do {
                guard let dict = data[0] as? [String: Any] else { return }
                let gameNotiRaw = try JSONSerialization.data(withJSONObject: dict["gameUpdate"] as Any, options: [])
                let gameNotiDecoded = try JSONDecoder().decode(GameStartingInfo.self, from: gameNotiRaw)
                self.toastMessage = gameNotiDecoded.message
                self.showToast.toggle()
            } catch let err {
                print(err)
            }
        }
        
        socket.on("payout started") { data, ack in
            guard let msg = data[0] as? String else { return }
            self.toastMessage = msg
            self.showToast.toggle()
        }
        
        socket.on("wallet txs") { data, ack in
            do {
                let noti = try JSONSerialization.data(withJSONObject: data[0])
                let decoded = try JSONDecoder().decode(Msg.self, from: noti)
                self.toastMessage = decoded.details
                self.showToast.toggle()
            } catch let err {
                print(err.localizedDescription)
            }
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
    
    func gameStartingNoti(walletAddr: String) {
        
        manager.defaultSocket.on("game starting") { data, ack in
            do {
                guard let dict = data[0] as? [String: Any] else { return }
                let gameNotiRaw = try JSONSerialization.data(withJSONObject: dict["gameUpdate"] as Any, options: [])
                let gameNotiDecoded = try JSONDecoder().decode(GameStartingInfo.self, from: gameNotiRaw)
                print("Your game noti is here: \(gameNotiDecoded) \n for wallet addy: \(walletAddr)")
            } catch let err {
                print(err)
            }
        }
    }
    
    func notificationsOnlyForMe() {
        manager.defaultSocket.on("wallet txs") { data, ack in
            do {
                let noti = try JSONSerialization.data(withJSONObject: data[0])
                let decoded = try JSONDecoder().decode(Msg.self, from: noti)
                self.toastMessage = decoded.details
                self.showToast.toggle()
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
    var details: String
    var escrowWallet: String
}

struct GameStartingNoti: Decodable {
    var gameUpdate: GameStartingInfo
}

struct GameStartingInfo: Decodable {
    var message: String
    var gameId: Int
}
