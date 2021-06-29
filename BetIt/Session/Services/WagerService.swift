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
    
    func getWagersForGameId(token: String, gameId: UInt, completion: @escaping (Result<[WagerModel], WagerErrors>) -> ()) {

        let reqWithoutBody = networker.constructRequest(uri: "http://localhost:3000/wager-handler/get-wagers-by-game", token: token, post: true)
      
        // set up the body of the request
        let body = ["gameId": gameId]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        // now set up the api hit
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil || data == nil {
                print("there was a big error: \(String(describing: error))")
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
    
    func updateWager(token: String, wagerId: Int, fader: String, completion: @escaping (Result<WagerModel, WagerErrors>) -> ()) {
        // TODO: add code that posts the updated wager to the back end
        let reqWithoutBody = networker.constructRequest(uri: "http://localhost:3000/wager-handler/add-fader-to-wager", token: token, post: true)
        
        let body: [String : Any] = ["wager_id": wagerId, "fader_address": fader]
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
 
        URLSession.shared.dataTask(with: request) {[weak self] (data, response, error) in
            guard let self = self else { return }
            
            if error != nil {
                print("there was a big error: \(String(describing: error))")
            }
//            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
//                print("Server error!")
//                return
//            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.generalError))
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
}
