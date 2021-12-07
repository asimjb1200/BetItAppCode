//
//  WagerService.swift
//  BetIt
//
//  Created by Asim Brown on 6/8/21.
//

import Foundation

class WagerService {
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    let tempAccessToken = ""
    let networker: Networker = .shared
    static let shared = WagerService()
    
    func getWagersForGameId(token: String, gameId: UInt, completion: @escaping (Result<[WagerModel], WagerErrors>) -> ()) {

        let reqWithoutBody = networker.constructRequest(uri: "https://www.bet-it-casino.com/wager-handler/get-wagers-by-game", token: token, post: true)
      
        // set up the body of the request
        let body = ["gameId": gameId]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        // now set up the api hit
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil || data == nil {
                print("there was a big error: \(String(describing: error))")
                completion(.failure(.generalError))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.generalError))
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }
            
            let isOK = self.networker.checkOkStatus(res: response)
            
            if !isOK {
                completion(.failure(.generalError))
            }
            
            guard let data = data else {
                completion(.failure(.generalError))
                return
            }
            
            do {
                // try to decode the wagers out of the api response
                let gameWagers = try self.decoder.decode([WagerModel].self, from: data)
            
                // send the wagers to the completion handler
                completion(.success(gameWagers))
                
            } catch let err {
                print("There was an error decoding the wagers: \(err)")
            }
        }.resume()
    }
    
    func getAllUsersWagers(token: String, bettor: String, completion: @escaping (Result<[WagerStatus], WagerErrors>) -> ()) {
        let req = networker.constructRequest(uri: "https://www.bet-it-casino.com/wager-handler/get-users-wagers?walletAddr=\(bettor)", token: token, post: false)

        URLSession.shared.dataTask(with: req) {[weak self] (data, res, err) in
            guard let self = self else {return}

            if err != nil {
                print("there was a big error: \(String(describing: err))")

            }
            guard let res = res as? HTTPURLResponse else {
                completion(.failure(.generalError))
                return
            }
            
            guard res.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }
            
            let isOK = self.networker.checkOkStatus(res: res)
            
            if !isOK {
                completion(.failure(.generalError))
            }
            
            guard let data = data else {
                completion(.failure(.generalError))
                return
            }
            print(data)

            do {
                // handle the UTC date format coming in from the db
                self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                let myWagers = try self.decoder.decode([WagerStatus].self, from: data)
                completion(.success(myWagers))
            } catch let decodeErr {
                print(decodeErr)
            }
            
            
        }.resume()
    }
    
    func updateWager(token: String, wagerId: Int, fader: String, completion: @escaping (Result<WagerModel, WagerErrors>) -> ()) {
        let reqWithoutBody = networker.constructRequest(uri: "https://www.bet-it-casino.com/wager-handler/add-fader-to-wager", token: token, post: true)
        
        let body: [String : Any] = ["wager_id": wagerId, "fader_address": fader]
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
 
        URLSession.shared.dataTask(with: request) {[weak self] (data, response, error) in
            guard let self = self else { return }
            
            if error != nil {
                print("there was a big error: \(String(describing: error))")
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.generalError))
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }
            
            let isOK = self.networker.checkOkStatus(res: response)
            if !isOK {
                completion(.failure(.generalError))
                return
            }
            
            // unwrapping the optional
            guard let data = data else {
                completion(.failure(.generalError))
                return
            }

            do {
                // try to decode the wagers out of the api response
                let gameWager = try self.decoder.decode(WagerModel.self, from: data)
                
                // send the wager to the completion handler
                completion(.success(gameWager))
            } catch let err {
                print(err)
            }
        }.resume()
    }
    
    func checkUserWagerCount(token: String, bettor: String, completion: @escaping (Result<Int, WagerErrors>) -> ()) {
        let request = networker.constructRequest(uri: "https://www.bet-it-casino.com/wager-handler/check-number-of-bets?walletAddress=\(bettor)", token: token)
        URLSession.shared.dataTask(with: request) {[weak self] (data, response, err) in
            guard let self = self else { return }
            if err != nil {
                print("there was a big error: \(String(describing: err))")
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.generalError))
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }
            
            let isOK = self.networker.checkOkStatus(res: response)
            
            // unwrapping the optional
            guard let data = data else {
                completion(.failure(.generalError))
                return
            }
            
            if isOK {
                do {
                    let numberOfWagers = try self.decoder.decode(WagerCountResponse.self, from: data)
                    completion(.success(numberOfWagers.numberOfBets))
                } catch let error {
                    print(error)
                    completion(.failure(.generalError))
                }
                
            }
        }.resume()
    }
    
    func createNewWager(token: String, bettor: String, wagerAmount: Decimal, gameId: UInt, bettorChosenTeam: UInt, completion: @escaping (Result<Bool, WagerErrors>) -> ()) {
        let reqWithoutBody = networker.constructRequest(uri: "https://www.bet-it-casino.com/wager-handler/create-wager", token: token, post: true)
        
        let body: [String : Any] = ["bettor": bettor, "wagerAmount": wagerAmount, "gameId": gameId, "bettorChosenTeam": bettorChosenTeam]
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
 
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            if error != nil {
                print("there was a big error: \(String(describing: error))")
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.generalError))
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }
            
            let isOK = self.networker.checkOkStatus(res: response)
            if !isOK {
                completion(.failure(.generalError))
                return
            }
            
            completion(.success(isOK))
        }.resume()
    }
    
    func cancelWager(token: String, wagerId: Int, completion: @escaping (Result<Bool, WagerErrors>) -> ()) {
        let reqWithoutBody = networker.constructRequest(uri: "https://www.bet-it-casino.com/wager-handler/delete-wager", token: token, post: true)
        let body: [String: Any] = ["wagerId": wagerId]
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        URLSession.shared.dataTask(with: request) {[weak self](_, response, err) in
            guard let self = self else { return }
            if err != nil {
                print("there was a big error: \(String(describing: err))")
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.generalError))
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }
            
            let isOK = self.networker.checkOkStatus(res: response)
            if !isOK {
                completion(.failure(.generalError))
                return
            }
            completion(.success(isOK))
        }.resume()
    }
}

struct WagerCountResponse: Decodable {
    var numberOfBets: Int
}

