//
//  WalletHistoryViewModel.swift
//  BetIt
//
//  Created by Asim Brown on 10/4/21.
//

import Foundation

final class WalletHistoryViewModel: ObservableObject {
    private var walletService: WalletService = .shared
    @Published var walletTransactions: [WalletTransactionPreview] = [WalletTransactionPreview]()
    
    func getWalletTxs(walletAddress: String, token: String) {
        walletService.getWalletHistory(walletAddress: walletAddress, token: token, completion: { [weak self] walletHistoyRes in
            switch walletHistoyRes {
            case .success(let walletHistory):
                DispatchQueue.main.async {
                    self?.walletTransactions = walletHistory
                }
            case .failure(let err):
                print(err)
            }
        })
    }
}
