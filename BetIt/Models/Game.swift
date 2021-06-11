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
        1: "ATL",
        2: "BOS",
        3: "BKN",
        4: "CHA",
        5: "CHI",
        6: "CLE",
        7: "DAL",
        8: "DEN",
        9: "DET",
        10: "GSW",
        11: "HOU",
        12: "IND",
        13: "LAC",
        14: "LAL",
        15: "MEM",
        16: "MIA",
        17: "MIL",
        18: "MIN",
        19: "NOP",
        20: "NYK",
        21: "OKC",
        22: "ORL",
        23: "PHI",
        24: "PHX",
        25: "POR",
        26: "SAC",
        27: "SAS",
        28: "TOR",
        29: "UTA",
        30: "WAS"
    ]
}

enum CustomError: String, Error {

    case invalidResponse = "The response from the server was invalid."
    case invalidData = "The data received from the server was invalid."

}

enum GameFetchError: String, Error {
    case noGamesFound = "No games on this date"
    case serverError = "There was an error on the server"
    case decodingError = "Had a problem when decoding the games from the server"
}
