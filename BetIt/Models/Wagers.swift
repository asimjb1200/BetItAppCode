//
//  Wagers.swift
//  BetIt
//
//  Created by Asim Brown on 6/5/21.
//

import Foundation

//struct Wager: Codable, Hashable {
//    let id: UInt
//    var bettor: String
//    var fader: String?
//    var wager_amount: UInt
//    let game_id: UInt
//    var is_active: Bool
//    var bettor_chosen_team: UInt8
//    var winning_team: UInt8?
//    var escrow_address: String?
////    init(
////        id: UInt, bettor: String,
////        wager_amount: UInt, game_id: UInt, is_active: Bool,
////        bettor_chosen_team: UInt8, escrow_address: String
////    )
////    {
////        self.id = id
////        self.bettor = bettor
////        self.wager_amount = wager_amount
////        self.game_id = game_id
////        self.is_active = is_active
////        self.bettor_chosen_team = bettor_chosen_team
////        self.escrow_address = escrow_address
////    }
//}

enum WagerErrors: String, Error {
    case noWagersFound = "Not able to find wagers for that game's id"
    case wagerOver = "This wager has been settled already"
    case generalError = "There was an error with the request"
}
