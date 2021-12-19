//
//  DeactivateAccountViewModel.swift
//  BetIt
//
//  Created by Asim Brown on 12/18/21.
//

import Foundation

final class DeactivateAccountViewModel: ObservableObject {
    private var userService: UserNetworking = .shared
    private var walletService: WalletService = .shared
    @Published var deletionComplete: Bool = false
    @Published var walletHasBalance: Bool = false
    func deactivateAccount(user: UserModel) {
        userService.deleteAccount(token: user.accessToken, completion: {(deletionResponse) in
            switch (deletionResponse) {
                case .success( _):
                    DispatchQueue.main.async {
                        self.deletionComplete = true
                    }
                case .failure(let err):
                    if err == .tokenExpired {
                        DispatchQueue.main.async {
                            user.logUserOut()
                        }
                    } else {
                        print(err.localizedDescription)
                    }
            }
        })
    }
    
    func checkWalletBalance(user: UserModel) {
        walletService.getWalletBalance(address: user.walletAddress, username: user.username, token: user.accessToken, completion: {[weak self](walletRes) in
            switch (walletRes) {
            case .success(let wallet):
                DispatchQueue.main.async {
                    if wallet.balance > 0 {
                        self?.walletHasBalance = true
                    }
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
}
