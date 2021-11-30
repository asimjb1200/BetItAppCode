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

        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "https://bet-it-casino.com/users/login", post: true)
        
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
                completion(.failure(.badCreds))
                return
            }

            guard let data = data else {
                completion(.failure(.failure))
                return
            }

            do {
                let serviceUser = try ServiceUser.decoder.decode(ServiceUser.self, from: data)
                completion(.success(serviceUser))
            } catch let error {
                print("problem occurred when trying to decode the user object: \(error)")
                completion(.failure(.failure))
            }
        }.resume()
    }
    
    func logout(accessToken: String, completion: @escaping (Result<Bool, LogoutErrors>) -> ()) {
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "https://www.bet-it-casino.com/users/logout", token: accessToken, post: true)
        let session = URLSession.shared
        
        session.dataTask(with: reqWithoutBody) { (_, response, err) in
            if err != nil {
                print("there was a big error: \(String(describing: err))")
                completion(.failure(.serverError))
            }
            
            // check for the OK status code
            guard
                let response = response as? HTTPURLResponse,
                200...299 ~= response.statusCode
            else {
                return
            }
            
            completion(.success(true))
            
        }.resume()
    }
    
    func refreshAccessToken(refreshToken: String, completion: @escaping (Result<String, RefreshTokenErrors>) -> ()) {
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "https://www.bet-it-casino.com/users/refresh-token", post: true)
        let session = URLSession.shared
        let body = ["token": refreshToken]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        session.dataTask(with: request) {(data, response, err) in
            if err != nil || data == nil {
                print("There was an error on the server: \(String(describing: err))")
                completion(.failure(.internalServerError))
            }
            
            guard
                let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode
            else {
                print("refresh token probably expired")
                completion(.failure(.tokenExpired))
                return
            }
            
            guard let data = data else {
                completion(.failure(.dataConversionError))
                return
            }
            
            do {
                let newAccessToken = try JSONDecoder().decode(String.self, from: data)
                completion(.success(newAccessToken))
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
    func changePassword(newPassword: String, username: String, oldPassword: String, token: String, completion: @escaping (Result<PasswordStates, UpdatePasswordErrors>) -> ()) {
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "https://www.bet-it-casino.com/users/change-password", token: token, post: true)
        
        let body = ["username": username, "newPassword": newPassword, "oldPassword": oldPassword]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        URLSession.shared.dataTask(with: request) { (_, response, err) in
            if err != nil {
                print("Something went bad with the request: \(String(describing: err))")
                completion(.failure(.generalError))
            }
            
            guard
                let response = response as? HTTPURLResponse
            else {
                completion(.failure(.couldNotSave))
                return
            }
            
            if response.statusCode ~= 200 {
                completion(.success(.updated))
            } else if response.statusCode ~= 403 {
                completion(.success(.incorrectPassword))
            } else if response.statusCode ~= 404 {
                completion(.success(.passwordNotFound))
            } else {
                completion(.failure(.generalError))
            }
            
        }.resume()
    }
    
    func changeEmail(username: String, password: String, email: String, token: String, completion: @escaping (Result<EmailStates, EmailStatesErrors>) -> ()) {
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "https://www.bet-it-casino.com/users/change-email", token: token, post: true)
        
        let body = ["username": username, "password": password, "newEmail": email]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        URLSession.shared.dataTask(with: request) { (_, response, err) in
            if err != nil {
                print("Something went bad with the request: \(String(describing: err))")
                completion(.failure(.generalError))
            }
            
            guard
                let response = response as? HTTPURLResponse
            else {
                completion(.failure(.couldNotSave))
                return
            }
            
            if response.statusCode ~= 200 {
                completion(.success(.updated))
            } else if response.statusCode ~= 403 {
                completion(.success(.incorrectPassword))
            } else if response.statusCode ~= 404 {
                completion(.success(.usernameNotFound))
            } else {
                completion(.failure(.generalError))
            }
        }.resume()
    }
    
    func registerUser(username: String, password: String, email: String, completion: @escaping (Result<Bool, UserErrors>) -> () ) {
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "https://www.bet-it-casino.com/users/register", post: true)
        
        let body = ["username": username, "password": password, "email": email]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        URLSession.shared.dataTask(with: request) { (_, res, err) in
            if err != nil {
                print("there was a big error: \(String(describing: err))")
                completion(.failure(.failure))
            }
            
            guard let res = res as? HTTPURLResponse else {
                completion(.failure(.failure))
                return
            }
            let isOK = self.networker.checkOkStatus(res: res)
            
            if !isOK {
                completion(.failure(.failure))
            }
            
            completion(.success(true))
        }.resume()
    }
}

enum RefreshTokenErrors: String, Error {
    case tokenExpired = "User's refresh token has expired. They must login again."
    case internalServerError = "There was an error on the server. User must login again."
    case dataConversionError = "There was a problem decoding the refresh token from the server"
}

enum UpdatePasswordErrors: String, Error {
    case userNotFound = "That username was not found"
    case couldNotSave = "The new password couldn't be saved to the database"
    case generalError = "Something went wrong with the request"
}

enum EmailStatesErrors: String, Error {
    case userNotFound = "That username was not found"
    case couldNotSave = "The new email couldn't be saved to the database"
    case generalError = "Something went wrong with the request"
}

enum EmailStates: Int {
    case updated = 0
    case incorrectPassword = 1
    case usernameNotFound = 2
    case noActionYet = 3
    case passwordOrEmailEmpty = 5
}
