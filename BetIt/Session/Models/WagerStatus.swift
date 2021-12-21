//
//  WagerStatus.swift
//  BetIt
//
//  Created by Asim Brown on 8/20/21.
//

import Foundation

struct WagerStatus: Codable, Hashable {
    var wagerId: Int
    var isActive: Bool
    var amount: Decimal
    var gameStartTime: Date
    var chosenTeam: Int
}
