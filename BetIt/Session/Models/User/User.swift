//
//  User.swift
//  BetIt
//
//  Created by Asim Brown on 5/30/21.
//

import Foundation

final class User: UserProtocol, ObservableObject, Identifiable {
    
    let username: String
    let accessToken: String
    let refreshToken: String
    let exp: Int
    let walletAddress: String
    
    @Published private(set) var isLoggedIn: Bool
    
    init(
        username: String,
        accessToken: String,
        refreshToken: String,
        isLoggedIn: Bool = false,
        exp: Int,
        walletAddress: String
    ) {
        self.username = username
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.isLoggedIn = isLoggedIn
        self.exp = exp
        self.walletAddress = walletAddress
    }
    
    deinit {
        print("being destroyed")
    }
}

extension User {
    
    static func from(_ serviceUser: ServiceUser, isLoggedIn: Bool) -> User {
        
        return .init(
            username: serviceUser.username,
            accessToken: serviceUser.accessToken,
            refreshToken: serviceUser.refreshToken,
            isLoggedIn: isLoggedIn,
            exp: serviceUser.exp,
            walletAddress: serviceUser.walletAddress
        )
    }
}
