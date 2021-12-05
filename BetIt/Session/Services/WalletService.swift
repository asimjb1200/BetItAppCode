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
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "https://www.bet-it-casino.com/wallet-handler/get-wallet-balance", token: token, post: true)
        
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
    
    func getCurrentLtcPrice(completion: @escaping (Result<CoinbasePriceDataResponse, CoinbaseErrors>) -> ()) {
        let req: URLRequest = networker.constructRequest(uri: "https://api.coinbase.com/v2/prices/LTC-USD/buy")
        let session = URLSession.shared
        session.dataTask(with: req) { (data, response, error) in
            if error != nil || data == nil {
                print("there was a big error: \(String(describing: error))")
                completion(.failure(.failure))
            }
            
            guard let response = response else {
              print("Cannot find the response")
                completion(.failure(.failure))
                return
            }
            let httpResponse = response as! HTTPURLResponse
            
            if httpResponse.statusCode == 200 {
                guard let data = data else {
                    completion(.failure(.failure))
                    return
                }
                
                do {
                    let priceData = try self.decoder.decode(CoinbasePriceDataResponse.self, from: data)
                    completion(.success(priceData))
                    print(priceData)
                } catch let err {
                    print(err)
                }
            } else {
                completion(.failure(.failure))
            }
        }.resume()
    }
    
    @available(iOS 15.0.0, *)
    func fetchLtcPriceAsync() async throws -> String {
        guard let url = URL(string: "https://api.coinbase.com/v2/prices/LTC-USD/buy") else {
            throw CoinbaseErrors.invalidURL
        }
        
        // use async version of URLSession
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // parse the JSON data
        let coinbasePriceResponse = try JSONDecoder().decode(CoinbasePriceDataResponse.self, from: data)
        return coinbasePriceResponse.data.amount
    }
    
    func transferFromWallet(fromAddress: String, toAddress: String, ltcAmount: Decimal, token: String, completion: @escaping (Result<Bool, WalletErrors>) -> ()) {
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "https://www.bet-it-casino.com/wallet-handler/pay-user", token: token, post: true)
        
        let body:[String: Any] = ["fromAddress":fromAddress, "toAddress":toAddress, "ltcAmount":ltcAmount]
        let session = URLSession.shared
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        session.dataTask(with: request) { (_, response, error) in
            if error != nil {
                print("there was a big error: \(String(describing: error))")
                completion(.failure(.serverError))
            }
            
            let httpResponse = response as! HTTPURLResponse
            
            guard
                httpResponse.statusCode == 200
            else {
                completion(.failure(.serverError))
                return
            }
            
            completion(.success(true))
        }
        .resume()
        
    }
    
    func getWalletHistory(walletAddress: String, token: String, completion: @escaping (Result<[WalletTransactionPreview], WalletErrors>) -> ()) {
        let requestWithoutBody: URLRequest = networker.constructRequest(uri: "https://www.bet-it-casino.com/wallet-handler/wallet-history/\(walletAddress)", token: token, post: false)
        
        let session = URLSession.shared
        
        // let dateFormatter = DateFormatter()
        // handle the UTC date format coming in from the db. These timestamps are coming back in ISO8601 format
        self.decoder.dateDecodingStrategy = .iso8601
        
        // sometimes the dates will have yyyy-MM-dd'T'HH:mm:sssZ instead of yyyy-MM-dd'T'HH:mm:ssZ
        // is there a way that I can parse both without punk ass swift breaking?
        
        session.dataTask(with: requestWithoutBody) { (data, response, error) in
            if error != nil {
                print("Something occurred on the server")
                completion(.failure(.serverError))
            }
            
            guard let response = response else {
                print("There was an error on the server")
                completion(.failure(.serverError))
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            
            if httpResponse?.statusCode == 200 {
                guard let data = data else {
                    completion(.failure(.serverError))
                    return
                }
                
                do {
                    let walletLedger = try self.decoder.decode([WalletTransactionPreview].self, from: data)
                    completion(.success(walletLedger))
                } catch let err {
                    DispatchQueue.main.async {
                        print(err.localizedDescription)
                    }
                    completion(.failure(.serverError))
                }
            }
        }.resume()
    }
}

enum WalletErrors: String, Error {
    case walletNotFound = "There was no record of that wallet in the database"
    case notTheOwner = "That wallet doesn't belong to you"
    case serverError = "There was an error on the server"
}

extension DateFormatter {
  static let iso8601Full: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}
