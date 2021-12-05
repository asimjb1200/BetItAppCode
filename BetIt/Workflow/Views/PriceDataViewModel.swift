//
//  PriceDataViewModel.swift
//  BetIt
//
//  Created by Asim Brown on 12/4/21.
//

import Foundation

final class PriceDataViewModel: ObservableObject {
    @Published var currentPrice: String = "0.0"
    @Published var volume: Decimal = 0
    @Published var high: Decimal = 0
    @Published var low: Decimal = 0
    @Published var marketCap: Decimal = 0
    @Published var circSupply: Decimal = 0
    @Published var prevClose: Decimal = 0
    @Published var prevOpen: Decimal = 0
    let service: WalletService = .shared
    
    func getLtcPrice() {
        service.getCurrentLtcPrice(completion: {[weak self] (priceData) in
            switch priceData {
                case .success(let data):
                    DispatchQueue.main.async {
                        self?.currentPrice = data.data.amount
                    }
                case .failure(let err):
                    print(err)
            }
        })
    }

    @available(iOS 15.0, *)
    func fetchLtcPriceAsync() {
        Task {
            do {
                self.currentPrice = try await service.fetchLtcPriceAsync()
            } catch {
                print("Request failed with error: \(error)")
            }
        }
    }
    
    @available(iOS 15.0.0, *)
    func fetchLtcPrice() async throws -> String {
        let priceData: CoinbasePriceDataResponse = try await withCheckedThrowingContinuation({ continuation in
            service.getCurrentLtcPrice{ result in
                switch result {
                case .success(let prices):
                    continuation.resume(returning: prices)
                case.failure(let error):
                    continuation.resume(throwing: error)
                }
                
            }
        })
        return priceData.data.amount
    }
}

struct ITunesResult: Codable {
    let results: [Album]
}

struct Album: Codable, Hashable {
    let collectionId: Int
    let collectionName: String
    let collectionPrice: Double
}
