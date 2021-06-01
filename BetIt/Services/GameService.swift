//
//  GameService.swift
//  BetIt
//
//  Created by Asim Brown on 5/30/21.
//

import Foundation

class GameService {
    func getUpcomingGames(completion: @escaping (Result<[DBGame], CustomError>) -> Void) {
        let url = URL(string: "http://localhost:3000/sports-handler/bball/games-this-week")!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // check for error
            if error != nil || data == nil {
                completion(.failure(.invalidResponse))
                print("Client error!")
                return
            }
            
            // check for the OK status code
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                            print("Server error!")
                            return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                let games = try decoder.decode([DBGame].self, from: data)
                completion(.success(games))
            } catch let err {
                print("error fetching data: \(err)")
                completion(.failure(.invalidData))
            }
        }.resume()
        
    }
}
