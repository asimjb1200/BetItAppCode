//
//  UserProtocol.swift
//  BetIt
//
//  Created by Asim Brown on 6/29/21.
//

import Foundation

protocol UserProtocol {
    
    var username: String { get }
    var accessToken: String { get }
    var refreshToken: String { get }
    var exp: Int { get }
    var walletAddress: String { get }
}
