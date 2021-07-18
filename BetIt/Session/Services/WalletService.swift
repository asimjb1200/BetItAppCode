//
//  WalletService.swift
//  BetIt
//
//  Created by Asim Brown on 7/17/21.
//

import Foundation

final class WalletService {
    private var networker: Networker = .shared
    private let decoder = JSONDecoder()
    
    static let shared = WalletService()
    private init() {}
    
    func getWalletBalance(address: String, username: String, token: String, completion: @escaping (Result<WalletModel, WalletErrors>) -> ()) {
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:3000/wallet-handler/get-wallet-balance", token: token, post: true)
        
        let session = URLSession.shared
        let body = ["username": username, "address": address]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        session.dataTask(with: request) { (data, response, error) in
            if error != nil || data == nil {
                print("there was a big error: \(String(describing: error))")
                completion(.failure(.serverError))
            }
            
            guard let response = response else {
              print("Cannot find the response")
                completion(.failure(.serverError))
                return
            }
            let httpResponse = response as! HTTPURLResponse
            
            if httpResponse.statusCode == 200 {
                guard let data = data else {
                    completion(.failure(.serverError))
                    return
                }
                
                do {
                    let walletBalance = try self.decoder.decode(WalletModel.self, from: data)
                    completion(.success(walletBalance))
                } catch let err {
                    print(err)
                }
            } else if httpResponse.statusCode == 401 {
                completion(.failure(.notTheOwner))
            }
        }.resume()
    }
}

enum WalletErrors: String, Error {
    case walletNotFound = "There was no record of that wallet in the database"
    case notTheOwner = "That wallet doesn't belong to you"
    case serverError = "There was an error on the server"
}
