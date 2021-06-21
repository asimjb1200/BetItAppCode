//
//  User.swift
//  BetIt
//
//  Created by Asim Brown on 5/30/21.
//

import Foundation

class User: ObservableObject, Identifiable, Codable {
    var username: String = ""
    @Published var access_token: String = ""
    @Published var refresh_token: String = ""
    @Published var isLoggedIn = false
    @Published var exp: Int = 0
    var wallet_address: String = ""
    
    let decoder = JSONDecoder()
    
    static let shared = User()
    
    enum CodingKeys: CodingKey {
        case access_token, refresh_token, username, wallet_address, isLoggedIn, exp
    }
    
    // tell swift how to decode data into the published types
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        access_token = try container.decode(String.self, forKey: .access_token)
        refresh_token = try container.decode(String.self, forKey: .refresh_token)
        username = try container.decode(String.self, forKey: .username)
        wallet_address = try container.decode(String.self, forKey: .wallet_address)
        exp = try container.decode(Int.self, forKey: .exp)
//        isLoggedIn = try container.decode(Bool.self, forKey: .isLoggedIn)
    }
    
    init() {}

//    init(username: String, access_token: String, refresh_token: String, wallet_address: String, exp: Int) {
//        self.username = username
//        self.access_token = access_token
//        self.refresh_token = refresh_token
//        self.wallet_address = wallet_address
//        self.exp = exp
//    }
    
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(access_token, forKey: .access_token)
        try container.encode(refresh_token, forKey: .refresh_token)
        try container.encode(username, forKey: .username)
        try container.encode(wallet_address, forKey: .wallet_address)
//        try container.encode(isLoggedIn, forKey: .isLoggedIn)
    }
    
    func login(username:String, pw: String, completion: @escaping (Result<User, UserErrors>) -> ()) {
        let url = URL(string: "http://localhost:3000/users/login")!
        var session = URLSession.shared
        
        let body = ["username": username, "password": pw]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Unable to serialize into JSON")
            return
        }
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        session.dataTask(with: request) {(data, response, err) in
            // check for the OK status code
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            
            if err != nil || data == nil {
                print("there was a big error: \(String(describing: err))")
                completion(.failure(.failure))
            }
            
            guard let data = data else {
                completion(.failure(.failure))
                return
            }
            
            do {
                let userData = try self.decoder.decode(User.self, from: data)
                print(userData)
                completion(.success(userData))
            } catch let error {
                print("problem occurred when trying to decode the user object: \(error)")
                completion(.failure(.failure))
            }
        }.resume()
    }
    
    func logout() {
        
    }
}

enum UserErrors: String, Error {
    case success = "Successfully logged in user"
    case failure = "Not abble to log user in"
}
