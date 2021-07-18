//
//  WalletDetailsViewModel.swift
//  BetIt
//
//  Created by Asim Brown on 7/8/21.
//

import Foundation

final class WalletDetailsViewModel: ObservableObject {
    @Published var ltcBalance: Decimal = 0.0
    @Published var dollarBalance: Decimal = 0.0
    var walletService: WalletService = .shared
    
    private var escrowAddress: String = "testStringHere"
    
    func getLtcBalance(username: String, address: String, token: String) -> () {
        print("getLtcBalance being called")
        walletService.getWalletBalance(address: address, username: username, token: token, completion: { (walletData) in
            switch walletData {
                case .success(let balPresent):
                    print(balPresent)
                    DispatchQueue.main.async {
                        self.ltcBalance = balPresent.balance
                        self.dollarBalance = balPresent.dollarEquivalent
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
