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
    @Published var txsLoading: Bool = true
    
    func getWalletTxs(walletAddress: String, token: String, user: UserModel) {
        walletService.getWalletHistory(walletAddress: walletAddress, token: token, completion: { [weak self] walletHistoyRes in
            switch walletHistoyRes {
            case .success(let walletHistory):
                DispatchQueue.main.async {
                    self?.walletTransactions = walletHistory.dataForClient
                    self?.txsLoading.toggle()
                    
                    guard let newAccessToken = walletHistory.newAccessToken else { return }
                    user.accessToken = newAccessToken
                }
            case .failure(let err):
                if err == .tokenExpired {
                    user.logUserOut()
                }
                print(err)
            }
        })
    }
}
