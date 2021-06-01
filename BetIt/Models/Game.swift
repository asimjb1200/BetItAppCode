//
//  Game.swift
//  BetIt
//
//  Created by Asim Brown on 5/30/21.
//

import Foundation

struct DBGame: Codable, Hashable {
    var game_id: UInt
    var sport: String
    var home_team: UInt8
    var visitor_team: UInt8
    var game_begins: Date
    var home_score: UInt8?
    var away_score: UInt8?
    var winning_team: UInt8?
    var season: UInt
}

enum CustomError: String, Error {

    case invalidResponse = "The response from the server was invalid."
    case invalidData = "The data received from the server was invalid."

}
