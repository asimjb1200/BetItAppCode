//
//  UserService.swift
//  BetIt
//
//  Created by Asim Brown on 6/29/21.
//

import Foundation
import Security

final class UserNetworking {
    let networker: Networker = .shared
    static let shared: UserNetworking = UserNetworking()
    private let keyChainLabel = "bet-it-casino-access-token"
    
    func login(username:String, pw: String, completion: @escaping (Result<ServiceUser, UserErrors>) -> ()) {

        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:4000/users/login", post: true)
        
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
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:4000/users/logout", token: accessToken, post: true)
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
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:4000/users/refresh-token", post: true)
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
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:4000/users/change-password", token: token, post: true)
        
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
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:4000/users/change-email", token: token, post: true)
        
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
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:4000/users/register", post: true)
        
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
            } else {
                completion(.success(true))
            }
        }.resume()
    }
    
    func emailSupport(subject: String, message: String, token: String, completion: @escaping (Result<Bool, SupportErrors>) -> ()) {
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:4000/users/email-support", token: token, post: true)
        let session = URLSession.shared
        let body = ["subject": subject, "message": message]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        session.dataTask(with: request) {(_, response, error) in
            if error != nil {
                print("there was an error with the request")
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            let isOK = self.networker.checkOkStatus(res: response)
            if isOK {
                completion(.success(true))
            } else if response.statusCode ~= 403 {
                completion(.failure(.tokenExpired))
            } else {
                completion(.failure(.serverError))
            }
        }.resume()
    }
    
    func deleteAccount(token: String, completion: @escaping (Result<Bool, AccountErrors>) -> ()) {
        let req: URLRequest = networker.constructRequest(uri: "http://localhost:4000/users/deactivate-account", token: token, post: false)
        let session = URLSession.shared
        
        session.dataTask(with: req) {(_, response, error) in
            if error != nil {
                print("There was an error with the request")
            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }

            let isOK = self.networker.checkOkStatus(res: response)

            if response.statusCode ~= 403 {
                completion(.failure(.tokenExpired))
            } else if isOK {
                completion(.success(true))
            } else {
                completion(.failure(.serverError))
            }
        }
    }
    
    func saveAccessToken(accessToken: String) {
        // save the access token to the device in a set place
        let key = accessToken
        let addquery = [
            kSecClass: kSecClassKey,
            kSecAttrLabel: self.keyChainLabel,
            kSecValueData: Data(key.utf8)
        ] as CFDictionary
        
        let status = SecItemAdd(addquery, nil)
        print("Save operation finished with status: \(status)")
    }
    
    func saveUserToDevice(user: ServiceUser) {
        let defaults: UserDefaults = .standard
        // store the user's info
        defaults.set(user.username, forKey: "Username")
        defaults.set(user.walletAddress, forKey: "WalletAddr")
    }
    
    func loadUserFromDevice() -> UserModel? {
        let defaults: UserDefaults = .standard
        let username = defaults.string(forKey: "Username")
        let walletAddr = defaults.string(forKey: "WalletAddr")
        guard
            let username = username,
            let walletAddr = walletAddr
        else {
            return nil
        }

        // let serviceUser: ServiceUser = ServiceUser(username: username, accessToken: "", refreshToken: "", exp: 0, walletAddress: walletAddr)
        let user: UserModel = .buildUser(username: username, access_token: "", refresh_token: "", wallet_address: walletAddr, exp: 0, isLoggedIn: false)
        
        return user
    }
    
    func updateAccessToken(newToken: String) {
        let findTokenQuery = [
            kSecClass: kSecClassKey,
            kSecAttrLabel: self.keyChainLabel
        ] as CFDictionary
        
        let updateQuery = [
            kSecValueData: Data(newToken.utf8)
        ] as CFDictionary
        
        let status = SecItemUpdate(findTokenQuery, updateQuery)
        print("Update Finished with a status of \(status)")
    }
    
    func deleteAccessToken() {
        let delquery = [
            kSecClass: kSecClassKey,
            kSecAttrLabel: self.keyChainLabel
        ] as CFDictionary
        let status = SecItemDelete(delquery)
        print("Delete operation finished with status: \(status)")
    }
    
    func loadAccessToken() -> String? {
        let getquery = [
            kSecClass: kSecClassKey,
            kSecAttrLabel: self.keyChainLabel,
            kSecReturnData: true,
            kSecReturnAttributes: true
        ] as CFDictionary
        
        var item: AnyObject?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        print("Load operation finished with status: \(status)")
        let dict = item as? NSDictionary
        if dict != nil {
            let keyData = dict![kSecValueData] as! Data
            let accessToken = String(data: keyData, encoding: .utf8)!
            print("Loaded access token: \(accessToken)")
            return accessToken
        } else {
            return nil
        }
    }
}

enum AccountErrors: String, Error {
    case tokenExpired = "User's refresh token has expired. They must login again."
    case serverError = "There was an error on the server."
    case responseConversionError = "There was a problem when trying to decode the response"
}

enum RefreshTokenErrors: String, Error {
    case tokenExpired = "User's refresh token has expired. They must login again."
    case internalServerError = "There was an error on the server. User must login again."
    case dataConversionError = "There was a problem decoding the refresh token from the server"
}

enum SupportErrors: String, Error {
    case tokenExpired = "The access token has expired. Time to issue a new one"
    case requestError = "There was a problem making the request."
    case serverError = "There was an error with the request on the server."
    case responseConversionError = "Unable to decode http response."
}

enum UpdatePasswordErrors: String, Error {
    case userNotFound = "That username was not found"
    case couldNotSave = "The new password couldn't be saved to the database"
    case generalError = "Something went wrong with the request"
    case tokenExpired = "The access token has expired. Time to issue a new one"
}

enum EmailStatesErrors: String, Error {
    case userNotFound = "That username was not found"
    case couldNotSave = "The new email couldn't be saved to the database"
    case generalError = "Something went wrong with the request"
    case tokenExpired = "The access token has expired. Time to issue a new one"
}

enum EmailStates: Int {
    case updated = 0
    case incorrectPassword = 1
    case usernameNotFound = 2
    case noActionYet = 3
    case passwordOrEmailEmpty = 5
}
