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
    func establishConnection() {
        socket.connect()
        print("Connected to Socket !")
    }

    //Function to close established socket connection. Call this method from `applicationDidEnterBackground` in your `Appdelegate` method.
    func closeConnection() {
        socket.disconnect()
        print("Disconnected from Socket !")
    }
    
    func getUpdatedWagers(completionHandler: @escaping (Result<WagerModel, Error>) -> ()) {
        socket.on("wager updated") { data, ack in
            do {
                guard let dict = data[0] as? [String: Any] else { return }
//                let wagerData = try WagerModel(from: dict["wager"] as! Decoder)
                let wagerData = try JSONSerialization.data(withJSONObject: dict["wager"] as Any, options: [])
                let decoded = try JSONDecoder().decode(WagerModel.self, from: wagerData)
                completionHandler(.success(decoded))
            } catch let err {
                print(err)
            }
            
//            guard let dict = data.first as? [String: Any] else { return }
//            guard let updatedWager: WagerModel = (dict["wager"] as? WagerModel) else {
//                return
//            }
//            print(updatedWager)
//            completionHandler(.success(updatedWager))
        }
    }
}
