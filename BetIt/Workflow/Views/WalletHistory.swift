//
//  WalletHistory.swift
//  BetIt
//
//  Created by Asim Brown on 10/4/21.
//

import SwiftUI

struct WalletHistory: View {
    @StateObject var viewModel: WalletHistoryViewModel = WalletHistoryViewModel()
    @EnvironmentObject private var user: UserModel
    var body: some View {
        ScrollView {
            if viewModel.txsLoading {
                LoadingView()
            } else {
                ForEach(viewModel.walletTransactions, id: \.self) { event in
                    WalletTransactionView(txInfo: event)
                }
            }
        }.onAppear() {
            viewModel.getWalletTxs(walletAddress: user.walletAddress, token: user.accessToken)
        }
    }
}

struct WalletHistory_Previews: PreviewProvider {
    static var previews: some View {
        WalletHistory()
    }
}
