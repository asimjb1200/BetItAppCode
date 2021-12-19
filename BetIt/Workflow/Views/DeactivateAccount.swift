//
//  DeactivateAccount.swift
//  BetIt
//
//  Created by Asim Brown on 12/17/21.
//

import SwiftUI

struct DeactivateAccount: View {
    @EnvironmentObject var user: UserModel
    @StateObject var viewModel = DeactivateAccountViewModel()
    var body: some View {
        if !viewModel.walletHasBalance {
            VStack {
                Text("Warning!")
                    .onAppear() {
                        viewModel.checkWalletBalance(user: user)
                    }
                    .font(.custom("MontserratAlternates-ExtraBold", size: 28))

                    Text("By deleting your account, you will no longer have access to the wallet that we've created for you. Make sure that you've removed any crypto from your wallet and sent it to another wallet that you control. Once your account is deleted, we can't get it back.")
                        .font(.custom("MontserratAlternates-Regular", size: 20))
                        .padding()
                    
                    Button("I'm sure I want to delete my account!") {
                        viewModel.deactivateAccount(user: user)
                    }
                    .foregroundColor(Color("Accent2"))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Text("Remove all crypto from your wallet before deleting your account.")
                .font(.custom("MontserratAlternates-Regular", size: 20))
        }
    }
}

struct DeactivateAccount_Previews: PreviewProvider {
    static var previews: some View {
        DeactivateAccount()
    }
}
