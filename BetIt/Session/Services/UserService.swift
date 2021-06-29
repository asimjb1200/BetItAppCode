//
//  UserService.swift
//  BetIt
//
//  Created by Asim Brown on 6/29/21.
//

import Foundation

class UserNetworking {
    let networker: Networker = .shared
    func login(username:String, pw: String, completion: @escaping (Result<ServiceUser, UserErrors>) -> ()) {

        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:3000/users/login", post: true)
        
        let session = URLSession.shared
        let body = ["username": username, "password": pw]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)

        session.dataTask(with: request) { (data, response, err) in
            
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
                print(serviceUser)
                completion(.success(serviceUser))
            } catch let error {
                print("problem occurred when trying to decode the user object: \(error)")
                completion(.failure(.failure))
            }
        }.resume()
    }
    
    func logout() {
        
    }
}
