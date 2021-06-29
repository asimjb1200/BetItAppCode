//
//  UserErrors.swift
//  BetIt
//
//  Created by Asim Brown on 6/29/21.
//

import Foundation

enum UserErrors: String, Error {
    case success = "Successfully logged in user"
    case failure = "Not abble to log user in"
}
