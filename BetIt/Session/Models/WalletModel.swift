//
//  WalletModel.swift
//  BetIt
//
//  Created by Asim Brown on 7/17/21.
//

import Foundation

struct WalletModel: Codable {
    let balance: Decimal
    var dollarEquivalent: Decimal
}
