//
//  UserErrors.swift
//  BetIt
//
//  Created by Asim Brown on 6/29/21.
//

import Foundation

enum UserErrors: String, Error {
    case success = "Successfully logged in user"
    case failure = "Not able to log user in"
    case badCreds = "Credentials weren't accepted by the server"
}

enum LogoutErrors: String, Error {
    case notFound = "User object could not be found"
    case serverError = "There was an error on the server side"
}
