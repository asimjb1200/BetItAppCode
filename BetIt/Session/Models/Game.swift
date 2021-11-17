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

struct TeamsMapper {
    let Teams: [UInt8: String] = [
        0: "N/A",
        1: "ATL",
        2: "BOS",
        4: "BKN",
        5: "CHA",
        6: "CHI",
        7: "CLE",
        8: "DAL",
        9: "DEN",
        10: "DET",
        11: "GSW",
        14: "HOU",
        15: "IND",
        16: "LAC",
        17: "LAL",
        19: "MEM",
        20: "MIA",
        21: "MIL",
        22: "MIN",
        23: "NOP",
        24: "NYK",
        25: "OKC",
        26: "ORL",
        27: "PHI",
        28: "PHX",
        29: "POR",
        30: "SAC",
        31: "SAS",
        38: "TOR",
        40: "UTA",
        41: "WAS"
    ]
}

enum CustomError: String, Error {
    case invalidResponse = "The response from the server was invalid."
    case invalidData = "The data received from the server was invalid."
}

enum GameFetchError: String, Error {
    case tokenExpired = "The access token has expired. Time to issue a new one"
    case noGamesFound = "No games on this date"
    case serverError = "There was an error on the server"
    case decodingError = "Had a problem when decoding the games from the server"
}
