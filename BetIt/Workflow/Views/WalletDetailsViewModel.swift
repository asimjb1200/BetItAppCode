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
    @Published var transferAmount: String = ""
    @Published var transferAddr: String = ""
    @Published var currLtcPrice: String = "1.0"
    @Published var showAlert: Bool = false
    @Published var txStarted: Bool = false
    @Published var showEmptyAddressAlert: Bool = false
    @Published var showEmptyAmountAlert: Bool = false
    @Published var cryptoTiedUpInWagers: Bool = false
    @Published var balanceIsLoading: Bool = true
    private var walletService: WalletService = .shared
    private var wagerService: WagerService = .shared
    
    private var escrowAddress: String = ""
    
    func getLtcBalance(username: String, address: String, token: String, user: UserModel) -> () {
        walletService.getWalletBalance(address: address, username: username, token: token, completion: {[weak self] (walletData) in
            switch walletData {
                case .success(let balPresent):
                    DispatchQueue.main.async {
                        self?.ltcBalance = NSDecimalNumber(decimal: balPresent.dataForClient.balance).doubleValue
                        self?.dollarBalance = NSDecimalNumber(decimal: balPresent.dataForClient.dollarEquivalent).doubleValue
                        self?.balanceIsLoading = false
                        
                        guard let newAccessToken = balPresent.newAccessToken else { return }
                        user.accessToken = newAccessToken
                    }
                case .failure(let err):
                    if err == .tokenExpired {
                        DispatchQueue.main.async {
                            user.logUserOut()
                        }
                    }
            }
        })
    }
    
    func getDollarBalance() -> Double {
        return 0
    }
    
    func transferFromWallet(fromAddress: String, token: String, user: UserModel) {
        walletService.transferFromWallet(fromAddress: fromAddress, toAddress: self.transferAddr, ltcAmount: self.calcLtcAmount(wagerAmountInDollars: self.transferAmount), token: token, completion: {[weak self] walletRes in
            switch walletRes {
                case .success( _):
                    DispatchQueue.main.async {
                        self?.txStarted.toggle()
                        self?.showAlert.toggle()
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        print(err)
                        if err == .tokenExpired {
                            user.logUserOut()
                        }
                        self?.showAlert.toggle()
                    }
            }
        })
    }
    
    func checkForLtcTiedUpInWagers(token: String, walletAddr: String, user: UserModel) -> () {
        wagerService.getAllUsersWagers(token: token, bettor: walletAddr, completion: { [weak self] wagerStatusArrayResponse in
            switch wagerStatusArrayResponse {
                case .success(let wagerStatusResponse):
                    DispatchQueue.main.async {
                        let totalLtcBal: Decimal = Decimal(self?.ltcBalance ?? 0.0)
                        guard
                            let ltcAmountToTransfer: Decimal = self?.calcLtcAmount(wagerAmountInDollars: self!.transferAmount)
                        else {
                            return
                        }
                        
                        var ltcAmountTiedUpInWagers: Decimal = 0
                        for wager in wagerStatusResponse.dataForClient {
                            if !wager.isActive { // wagers that aren't active haven't been taken out of the user's wallet yet. so I need to make sure that it can be covered
                                ltcAmountTiedUpInWagers += wager.amount
                            }
                        }
                        let ltcAvailableAfterWagers = totalLtcBal - ltcAmountTiedUpInWagers
                        
                        guard
                            ltcAvailableAfterWagers > 0.0,
                            ltcAvailableAfterWagers > ltcAmountToTransfer // this makes sure that there is enough crypto in their wallet to cover wagers 
                        else {
                            self?.cryptoTiedUpInWagers.toggle()
                            return
                        }

                        if let newAccessToken = wagerStatusResponse.newAccessToken {
                            user.accessToken = newAccessToken
                        }
                        self?.transferFromWallet(fromAddress: walletAddr, token: token, user: user)
                    }
                case .failure(let err):
                    if err == .tokenExpired {
                        DispatchQueue.main.async {
                            user.logUserOut()
                        }
                    }
            }
        })
    }
    
    func getCurrLtcPrice() {
        walletService.getCurrentLtcPrice(completion: {[weak self] ltcPriceDataRes in
            switch ltcPriceDataRes {
                case .success(let ltcPriceData):
                    DispatchQueue.main.async {
                        self?.currLtcPrice = ltcPriceData.data.amount
                    }
                case .failure(let err):
                    print(err)
            }
        })
    }
    
    func sendToEscrow() {
        
    }
    
    func depositToWallet() {
        
    }
    
    func calcLtcAmount(wagerAmountInDollars: String) -> Decimal {
        guard
            let usdDecimal = Decimal(string: wagerAmountInDollars)
        else {
            return 0
        }
        var rounded = Decimal()
        // find out how much ltc is needed to cover the bet
        var ltcAmountToWager: Decimal = usdDecimal/(Decimal(string: self.currLtcPrice) ?? 1.0)
        NSDecimalRound(&rounded, &ltcAmountToWager, 7, .bankers)
        return rounded
    }
    
}
