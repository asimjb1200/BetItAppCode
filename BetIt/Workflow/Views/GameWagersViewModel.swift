//
//  GameWagersViewModel.swift
//  BetIt
//
//  Created by Asim Brown on 7/8/21.
//

import Foundation

final class GameWagersViewModel: ObservableObject {
    @Published var wagers: [WagerModel] = []
    @Published var wagersNotFound: Bool = false
    @Published var usdPrice: Float = 0.0
    @Published var isLoading = true
    @Published var hasEnoughCrypto = true
    @Published var buttonPressed: Bool = false
    @Published var showingAlert = false
    @Published var gameStarts = Date()
    @Published var dataSubmitted = false
    static let shared = GameWagersViewModel()
    let service: WalletService = .shared
    let wagerService: WagerService = .shared
    
    // keep track of wagers that are updated
    init() {
        SocketIOManager.sharedInstance.getUpdatedWagers(completionHandler: { (newWager) in
            switch newWager {
            case .success(let wager):
                DispatchQueue.main.async {
                    if let index = self.wagers.firstIndex(where: {$0.id == wager.id}) {
                        self.wagers = self.wagers.filter{$0.id != wager.id}
                    }
                    if self.wagers.isEmpty {
                        self.wagersNotFound = true
                    }
                }
            case .failure(let err):
                print(err)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.wagersNotFound = true
                }
                
            }
        })
    }
    
    
    
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
    
    func getWagersByGameId(token: String, gameId: UInt, user: UserModel) {
        //self.wagers = []
        wagerService.getWagersForGameId(token: token, gameId: gameId, completion: {[weak self] (wagers) in
            switch wagers {
            case .success(let gameWagers):
                if gameWagers.dataForClient.isEmpty {
                    DispatchQueue.main.async {
                        self?.wagersNotFound = true
                        self?.isLoading = false
                        self?.wagers = []
                        guard let
                                newAccessToken = gameWagers.newAccessToken
                        else {
                            return // if newAccessToken is nil, the function will return and skip the code below
                        }
                        user.accessToken = newAccessToken
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.wagers = gameWagers.dataForClient
                        self?.wagersNotFound = false
                        self?.isLoading = false
                        
                        guard let
                                newAccessToken = gameWagers.newAccessToken
                        else {
                            return // if newAccessToken is nil, the function will return and skip the code below
                        }
                        user.accessToken = newAccessToken
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    if err == .tokenExpired {
                        user.logUserOut()
                    }
                }
                print("error occurred: \(err)")
            }
        })
    }
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: date)
    }
    
    
    func updateWager(token: String, wagerId: Int, fader: String, user: UserModel) {
        wagerService.updateWager(token: token, wagerId: wagerId, fader: fader, completion: {(updatedWager) in
            switch updatedWager {
                case .success(let newWagerResponse):
                    DispatchQueue.main.async {
                        self.wagers = self.wagers.filter{$0.id != newWagerResponse.dataForClient.id}
                        self.dataSubmitted = true
                        // disable the button to prevent double submittal
                        self.buttonPressed = true
                        
                        // inform the user that the bet has been successfully submitted
                        self.showingAlert = true
                        
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
    
    func bettorAndFaderAddressMatch(fader: String, bettor: String) -> Bool {
        return fader == bettor ? true : false
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
    
    deinit {
        print("Game wagers is being destroyed")
    }
}
