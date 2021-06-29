//
//  UserManager.swift
//  BetIt
//
//  Created by Asim Brown on 6/29/21.
//

import Foundation

final class UserManager: ObservableObject {
    
    @Published var user: User? // nil === !isLoggedIn
    
    static let shared = UserManager()
    let networker = Networker.shared
    
    private init() {}
    
    // TODO: - Check `isLoggedIn`.
    // FIXME
    func updateUser(with serviceUser: ServiceUser) {
        user = User.from(serviceUser, isLoggedIn: true)
        
        objectWillChange.send()
    }
    
}

extension UserManager {
    func login(username:String, pw: String, completion: @escaping (Result<ServiceUser, UserErrors>) -> ()) {

        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:3000/users/login", post: true)
        
        let session = URLSession.shared
        let body = ["username": username, "password": pw]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)

        session.dataTask(with: request) { [weak self] (data, response, err) in
            guard let self = self else {return}
            
            if err != nil || data == nil {
                print("there was a big error: \(String(describing: err))")
                completion(.failure(.failure))
            }
            
            // check for the OK status code
            guard
                let response = response as? HTTPURLResponse,
                200...299 ~= response.statusCode
            else {
                print("Server error!")
                return
            }

            guard let data = data else {
                completion(.failure(.failure))
                return
            }

            do {
                let serviceUser = try ServiceUser.decoder.decode(ServiceUser.self, from: data)
                //FIXME
                completion(.success(serviceUser))
            } catch let error {
                print("problem occurred when trying to decode the user object: \(error)")
                completion(.failure(.failure))
            }
        }.resume()
    }

    func logout(token: String, completion: @escaping (Result<User, UserErrors>) -> ()) {
        let session = URLSession.shared
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:3000/users/login", post: true)
        let body = ["token": token]
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        session.dataTask(with: request) { [weak self] (_, response, err) in
            guard let self = self else {return}
            
            if err != nil  {
                print("there was a big error: \(String(describing: err))")
                completion(.failure(.failure))
            }
            
            // check for the OK status code
            guard
                let response = response as? HTTPURLResponse,
                200...299 ~= response.statusCode
            else {
                print("Not able to log user out")
                return
            }

            do {
                
            } catch let error {
                print(error)
                completion(.failure(.failure))
            }
        }
    }
    
    func checkWalletBalance() {}
}
