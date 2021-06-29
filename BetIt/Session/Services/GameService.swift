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
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    let tempAccessToken = ""
    let networker: Networker = .shared
    
    func getUpcomingGames(completion: @escaping (Result<[DBGame], CustomError>) -> Void) {
        let url = URL(string: "http://localhost:3000/sports-handler/bball/games-this-week")!
//        let dateKey: String = self.convertDateToString(date: todaysDate)
        let cachedData: [DBGame]? = try? self.searchCacheForGamesByDate(dateKey: "210603")
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
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                do {
                    self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    
                    self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                    let games = try self.decoder.decode([DBGame].self, from: data)
                    
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
    
    func getGamesByDate(token: String, date: Date, completion: @escaping (Result<[DBGame], GameFetchError>) -> ()) {
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let stringifiedDate = self.dateFormatter.string(from: date)
        
        // set up the body of the request
        let body = ["date": stringifiedDate]
        
        // start preparing the url request
        let reqWithoutBody = networker.constructRequest(uri: "http://localhost:3000/sports-handler/bball/games-by-date", token: token, post: true)
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        // now create the request to be sent
        URLSession.shared.dataTask(with: request) {(data, response, err) in
            // check for the OK status code
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            
            if let err = err {
                // handle error
                print("error with request: \(err)")
            } else if let data = data {
                // convert the data to the type we can work with
                do {
                    // handle the UTC date format coming in from the db
                    self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    
                    self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                    let gameData = try self.decoder.decode([DBGame].self, from: data)
                    completion(.success(gameData))
                } catch let error {
                    print("problem occurred when turning response into DBGame: \(error)")
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
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
