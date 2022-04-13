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
    
    func getWagersByGameId(token: String, gameId: UInt, user: UserModel) {
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
}
