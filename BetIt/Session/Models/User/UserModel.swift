//
//  UserModel.swift
//  BetIt
//
//  Created by Asim Brown on 6/29/21.
//

import Foundation

class UserModel: ObservableObject, Identifiable, Codable {
     var username: String
     var accessToken: String
     var refreshToken: String
     @Published var isLoggedIn = false
     var exp: Int
     var walletAddress: String

     let decoder = JSONDecoder()

     enum CodingKeys: CodingKey {
         case accessToken, refreshToken, username, walletAddress, isLoggedIn, exp
     }

     // tell swift how to decode data into the published types
     required init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         accessToken = try container.decode(String.self, forKey: .accessToken)
         refreshToken = try container.decode(String.self, forKey: .refreshToken)
         username = try container.decode(String.self, forKey: .username)
         walletAddress = try container.decode(String.self, forKey: .walletAddress)
         exp = try container.decode(Int.self, forKey: .exp)
     }

    init(username: String, access_token: String, refresh_token: String, wallet_address: String, exp: Int, isLoggedIn: Bool) {
         self.username = username
         self.accessToken = access_token
         self.refreshToken = refresh_token
         self.walletAddress = wallet_address
         self.exp = exp
        self.isLoggedIn = isLoggedIn
     }

     func encode(to encoder: Encoder) throws {
         var container = try encoder.container(keyedBy: CodingKeys.self)
         try container.encode(accessToken, forKey: .accessToken)
         try container.encode(refreshToken, forKey: .refreshToken)
         try container.encode(username, forKey: .username)
         try container.encode(walletAddress, forKey: .walletAddress)
     }
}

extension UserModel {
    
    static func from(_ serviceUser: ServiceUser, isLoggedIn: Bool) -> UserModel {
        
        return .init(
            username: serviceUser.username,
            access_token: serviceUser.accessToken,
            refresh_token: serviceUser.refreshToken,
            wallet_address: serviceUser.walletAddress,
            exp: serviceUser.exp,
            isLoggedIn: isLoggedIn
        )
    }
    
    func logUserIn(usr: ServiceUser) -> () {
        self.username = usr.username
        self.accessToken = usr.accessToken
        self.refreshToken = usr.refreshToken
        self.walletAddress = usr.walletAddress
        self.exp = usr.exp
        self.isLoggedIn = true
    }
}
