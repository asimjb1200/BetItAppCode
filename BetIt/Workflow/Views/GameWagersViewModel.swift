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
    static let shared = GameWagersViewModel()
    let service: WalletService = .shared
    
    // keep track of wagers that are updated
    init() {
        SocketIOManager.sharedInstance.getUpdatedWagers(completionHandler: { (newWager) in
            switch newWager {
            case .success(let wager):
                DispatchQueue.main.async {
                    if let index = self.wagers.firstIndex(where: {$0.id == wager.id}) {
                        self.wagers = self.wagers.filter{$0.id != wager.id}
                    }
                }
            case .failure(let err):
                print(err)
            }
        })
    }
    
    func getWagersByGameId(token: String, gameId: UInt) {
        self.wagers = []
        WagerService().getWagersForGameId(token: token, gameId: gameId, completion: {[weak self] (wagers) in
            switch wagers {
            case .success(let gameWagers):
                if gameWagers.isEmpty {
                    DispatchQueue.main.async {
                        self?.wagersNotFound = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.wagers = gameWagers
                        self?.wagersNotFound = false
                    }
                }
            case .failure(let err):
                print("error occurred: \(err)")
            }
        })
    }
    
    func updateWager(token: String, wagerId: Int, fader: String) {
        WagerService().updateWager(token: token, wagerId: wagerId, fader: fader, completion: { [self] (updatedWager) in
            switch updatedWager {
            case .success(let newWager):
                DispatchQueue.main.async {
                    self.wagers = self.wagers.filter{$0.id != newWager.id}
                }
            case .failure(let err):
                print(err)
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
    
    deinit {
        print("Game wagers is being destroyed")
    }
}