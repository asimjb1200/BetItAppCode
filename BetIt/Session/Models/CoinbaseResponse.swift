//
//  CoinbaseResponse.swift
//  BetIt
//
//  Created by Asim Brown on 7/23/21.
//

import Foundation

struct CoinbasePriceDataResponse: Codable {
    var data: CoinbasePriceData
}

struct CoinbasePriceData: Codable {
    var amount: String
    var currency: String
    var base: String
}

enum CoinbaseErrors: String, Error {
    case success = "data found"
    case failure = "an error occurred"
    case invalidURL = "That URL is inactive"
}
