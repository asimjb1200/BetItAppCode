//
//  WagerStatus.swift
//  BetIt
//
//  Created by Asim Brown on 8/20/21.
//

import Foundation

struct WagerStatus: Decodable, Hashable {
    var isActive: Bool
    var amount: Int
    var gameStartTime: Date
    var chosenTeam: Int
}