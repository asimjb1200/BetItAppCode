//
//  Wagers.swift
//  BetIt
//
//  Created by Asim Brown on 6/5/21.
//

import Foundation

class WagerModel: ObservableObject, Identifiable, Codable{
    
    enum CodingKeys: CodingKey {
        case fader
        case wager_amount
        case is_active
        case winning_team
        case id
        case bettor
        case game_id
        case bettor_chosen_team
        case escrow_address
    }
    
    let id: Int
    let bettor: String
    @Published var fader: String?
    @Published var wager_amount: Decimal
    let game_id: Int
    @Published var is_active: Bool
    let bettor_chosen_team: UInt8
    @Published var winning_team: Int?
    @Published var escrow_address: String?
    
    // tell swift how to decode data into the published types
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        bettor = try container.decode(String.self, forKey: .bettor)
        game_id = try container.decode(Int.self, forKey: .game_id)
        bettor_chosen_team = try container.decode(UInt8.self, forKey: .bettor_chosen_team)
        fader = try container.decodeIfPresent(String.self, forKey: .fader)
        wager_amount = try container.decode(Decimal.self, forKey: .wager_amount)
        is_active = try container.decode(Bool.self, forKey: .is_active)
        winning_team = try container.decodeIfPresent(Int.self, forKey: .winning_team)
        escrow_address = try container.decodeIfPresent(String.self, forKey: .escrow_address)
    }
    
    init(id: Int, bettor: String, wager_amount: Decimal, game_id: Int, is_active: Bool, bettor_chosen_team: UInt8) {
        self.id = id
        self.bettor = bettor
        self.wager_amount = wager_amount
        self.game_id = game_id
        self.is_active = is_active
        self.bettor_chosen_team = bettor_chosen_team
    }
    
    // now tell swift how to encode my type
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(bettor, forKey: .bettor)
        try container.encodeIfPresent(fader, forKey: .fader)
        try container.encode(wager_amount, forKey: .wager_amount)
        try container.encode(game_id, forKey: .game_id)
        try container.encode(is_active, forKey: .is_active)
        try container.encodeIfPresent(winning_team, forKey: .winning_team)
        try container.encodeIfPresent(bettor_chosen_team, forKey: .bettor_chosen_team)
        try container.encodeIfPresent(escrow_address, forKey: .escrow_address)
    }
    
    deinit {
        print("A wager is being destroyed")
    }
}

enum WagerErrors: String, Error {
    case noWagersFound = "Not able to find wagers for that game's id"
    case wagerOver = "This wager has been settled already"
    case generalError = "There was an error with the request"
}
