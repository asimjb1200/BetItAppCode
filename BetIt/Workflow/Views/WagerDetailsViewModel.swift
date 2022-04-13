//
//  WagerDetailsViewModel.swift
//  BetIt
//
//  Created by Asim Brown on 1/5/22.
//

import Foundation
final class WagerDetailsViewModel: ObservableObject {
    @Published var dataSubmitted = false
    @Published var showingAlert = false
    @Published var buttonPressed = false
    @Published var hasEnoughCrypto = true
    @Published var gameStarts = Date()
    @Published var usdPrice: Float = 0.0
    private var service: WalletService = .shared
    private var wagerService: WagerService = .shared
    
    func getGameTime(gameId: UInt, user: UserModel) {
        GameService().getGameTime(gameId: gameId, token: user.accessToken, completion: { [weak self] gameTimeResult in
            switch gameTimeResult {
            case .success(let gameTimeResponse):
                DispatchQueue.main.async {
                    self?.gameStarts = gameTimeResponse.dataForClient.gameTime
                    guard let newAccessToken = gameTimeResponse.newAccessToken else {
                        return
                    }
                    user.accessToken = newAccessToken
                }
            case .failure(let err):
                print(err)
            }
        })
    }
    
    func getCurrentLtcPrice() {
        service.getCurrentLtcPrice(completion: {[weak self] (priceData) in
            switch priceData {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.usdPrice = Float(data.data.amount) ?? 0.0
                }
            case .failure(let err):
                print(err)
            }
        })
    }
    
    func checkWalletBalance(address: String, username: String, token: String, amount: Decimal, user: UserModel) {
        service.getWalletBalance(address: address, username: username, token: token, completion: {[weak self]  walletBalanceResponse in
            switch walletBalanceResponse {
                case .success(let walletResponse):
                    DispatchQueue.main.sync {
                        // let litoshiBalance = amount/100000000 // buffer room to work with tx fees
                        if walletResponse.dataForClient.balance <= amount {
                            self?.hasEnoughCrypto = false
                            self?.buttonPressed = true
                            self?.showingAlert = true
                        }
                        guard let newAccessToken = walletResponse.newAccessToken else {return}
                        user.accessToken = newAccessToken
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        if err == .tokenExpired {
                            user.logUserOut()
                        }
                        print(err)
                    }
            }
        })
    }
    
    func updateWager(token: String, wagerId: Int, fader: String, user: UserModel) {
        wagerService.updateWager(token: token, wagerId: wagerId, fader: fader, completion: {[weak self](updatedWager) in
            switch updatedWager {
                case .success(let newWagerResponse):
                    DispatchQueue.main.async {
                        //self.wagers = self.wagers.filter{$0.id != newWagerResponse.dataForClient.id}
                        self?.dataSubmitted = true
                        // disable the button to prevent double submittal
                        self?.buttonPressed = true
                        
                        // inform the user that the bet has been successfully submitted
                        self?.showingAlert = true
                        
                        guard let newAccessToken = newWagerResponse.newAccessToken else { return }
                        user.accessToken = newAccessToken
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        if err == .tokenExpired {
                            user.logUserOut()
                        }
                        print(err)
                    }
            }
        })
    }
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: date)
    }
}
