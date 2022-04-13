//
//  ServiceUser.swift
//  BetIt
//
//  Created by Asim Brown on 6/29/21.
//

import Foundation

struct ServiceUser: UserProtocol, Codable, HasJSONEncoder, HasJSONDecoder {
    
    let username: String
    let accessToken: String
    let refreshToken: String
    let exp: Int
    let walletAddress: String
}

extension ServiceUser {
    
    static func from(_ user: UserModel) -> ServiceUser {
        
        return .init(
            username: user.username,
            accessToken: user.accessToken,
            refreshToken: user.refreshToken,
            exp: user.exp,
            walletAddress: user.walletAddress
        )
    }
}
