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
    static let shared: GameService = GameService()
    
    func getGamesByDate(token: String, date: Date, completion: @escaping (Result<MainResponseToClient<[DBGame]>, GameFetchError>) -> ()) {
        // grab the user's current timezone so that I can process it in the db
        var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.timeZone = TimeZone.current
        let stringifiedDate = formatter.string(from: date)
        
        
        // set up the body of the request
        let body = ["date": stringifiedDate, "timeZone": localTimeZoneIdentifier]
        
        // start preparing the url request
        let reqWithoutBody = networker.constructRequest(uri: "http://localhost:4000/sports-handler/bball/games-by-date", token: token, post: true)
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        // now create the request to be sent
        URLSession.shared.dataTask(with: request) {(data, response, err) in
            // check for the OK status code
            guard let response = response as? HTTPURLResponse else {
                print("Server error!")
                return
            }
            
            if response.statusCode == 403 {
                completion(.failure(.tokenExpired))
            }
            
            if let err = err {
                // handle error
                print("error with request: \(err)")
            } else if let data = data {
                // convert the data to the type we can work with
                do {
                    // handle the UTC date format coming in from the db
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    
                    self.decoder.dateDecodingStrategy = .formatted(formatter)
                    let gameData = try self.decoder.decode(MainResponseToClient<[DBGame]>.self, from: data)
                    completion(.success(gameData))
                } catch let error {
                    print("problem occurred when turning response into DBGame: \(error)")
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    func getGameTime(gameId: UInt, token: String, completion: @escaping (Result<MainResponseToClient<GameTime>, CustomError>) -> ()) {
        
        let request = networker.constructRequest(uri: "http://localhost:4000/sports-handler/bball/get-game-time?gameId=\(gameId)", token: token)
        
        URLSession.shared.dataTask(with: request) {(data, response, err) in
            // check for the OK status code
            guard let response = response as? HTTPURLResponse else {
                print("Server error!")
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }
            
            guard response.statusCode != 500 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {return}
            
            do {
                print(data)
                
                // handle the UTC date format coming in from the db
                self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                
                let decodedData = try self.decoder.decode(MainResponseToClient<GameTime>.self, from: data)
                completion(.success(decodedData))
            } catch let err{
                print(err)
                completion(.failure(.invalidData))
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

struct GameTime: Codable {
    var gameTime: Date
}
