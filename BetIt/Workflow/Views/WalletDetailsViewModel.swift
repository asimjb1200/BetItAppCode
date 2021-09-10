//
//  WalletDetailsViewModel.swift
//  BetIt
//
//  Created by Asim Brown on 7/8/21.
//

import Foundation

final class WalletDetailsViewModel: ObservableObject {
    
    @Published var ltcBalance: Double = 0.0
    @Published var dollarBalance: Double = 0.0
    var walletService: WalletService = .shared
    
    private var escrowAddress: String = "testStringHere"
    
    func getLtcBalance(username: String, address: String, token: String) -> () {
        walletService.getWalletBalance(address: address, username: username, token: token, completion: { (walletData) in
            switch walletData {
                case .success(let balPresent):
                    DispatchQueue.main.async {
                        self.ltcBalance = NSDecimalNumber(decimal: balPresent.balance).doubleValue
                        self.dollarBalance = NSDecimalNumber(decimal: balPresent.dollarEquivalent).doubleValue
                    }
                case .failure(let err):
                    print(err)
            }
        })
    }
    
    func getDollarBalance() -> Double {
        return 0
    }
    
    func transferFromWallet() {
        
    }
    
    func sendToEscrow() {
        
    }
    
    func depositToWallet() {
        
    }
    
}
