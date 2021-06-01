//
//  GameService.swift
//  BetIt
//
//  Created by Asim Brown on 5/30/21.
//

import Foundation

class GameService {
    let fileManager = FileManager.default
    // grab the user's cache directory on their phone
    let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    
    func getUpcomingGames(completion: @escaping (Result<[DBGame], CustomError>) -> Void) {
        let url = URL(string: "http://localhost:3000/sports-handler/bball/games-this-week")!
        
        let cachedData = try? self.searchCacheForGamesByDate(dateKey: "210602")
        if (cachedData != nil) {
            completion(.success(cachedData!))
        } else {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                print("you've now hit the url")
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
                    
                    let dateKey = self.convertDateToString(date: games[0].game_begins)
                    
                    self.cacheGameSchedule(dateKey: dateKey, gamesThatDay: games)
                    
                    completion(.success(games))
                } catch let err {
                    print("error fetching data: \(err)")
                    completion(.failure(.invalidData))
                }
            }.resume()
        }
    }
    
    func searchCacheForGamesByDate(dateKey: String) -> [DBGame]? {
        print("You are now searching the cache")
        let decoder = JSONDecoder()
        // create a new file for the specific date
        let fileUrl = cachesDir.appendingPathComponent("\(dateKey)-games").appendingPathExtension("json")
        let filePath = fileUrl.path
        
        if (fileManager.fileExists(atPath: filePath)) {
            do {
                let gamesTodayJson = try Data(contentsOf: fileUrl)
                let gamesTodayEncoded = try decoder.decode([DBGame].self, from: gamesTodayJson)
//                print(gamesTodayEncoded)
                return gamesTodayEncoded
            } catch let err {
                print("problem reading from file or encoding as game type: \(err)")
            }
        } else {
            return nil
        }
        return nil
    }
    
    func cacheGameSchedule(dateKey: String, gamesThatDay: [DBGame]) -> (){
        // create a new file for the specific date
        let fileUrl = cachesDir.appendingPathComponent("\(dateKey)-games").appendingPathExtension("json")
        let filePath = fileUrl.path
        
        // encode the data to a json string for storage
        let encoder = JSONEncoder()
        
        guard let saveMe = try? encoder.encode(gamesThatDay) else {
            return
        }
        
        if (!fileManager.fileExists(atPath: filePath)) {
            do {
                // now save the json to the file
                try saveMe.write(to: fileUrl)
            } catch let writeErr {
                print("Problem writing to file: \(writeErr)")
            }
            print("File \(filePath) created")
            
        } else {
            print("File \(filePath) already exists")
        }
    }
    
    func convertDateToString(date: Date) -> String {
        // dates are changed to this format 2020-12-23 00:00:00 +0000
        // Create Date
        let date = Date()

        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "YYMMdd"

        // Convert Date to String
        let newDate = dateFormatter.string(from: date)
        
        return newDate;
    }
}
