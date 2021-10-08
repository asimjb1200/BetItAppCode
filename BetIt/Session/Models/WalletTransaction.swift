//
//  WalletTransaction.swift
//  BetIt
//
//  Created by Asim Brown on 10/4/21.
//

import Foundation

struct WalletTransactionPreview: Codable, Hashable {
    var date: Date
    var ltcAmount: Decimal
    var received: Bool
    var fromAddress: String
    var fees: Decimal
    var toAddress: String
}

struct WalletTransactionDetails {
    
}
