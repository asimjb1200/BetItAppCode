//
//  WalletTransactionsView.swift
//  BetIt
//
//  Created by Asim Brown on 9/7/21.
//

import SwiftUI

struct WalletTransactionView: View {
    var txInfo: WalletTransactionPreview
    @EnvironmentObject var user: UserModel
    var body: some View {
        VStack(alignment: .leading) {
            Text("Date Received: \(formatDate(date: txInfo.date))")
            Text("Value: \(NSDecimalNumber(decimal: roundDecimal(amount: txInfo.ltcAmount)).stringValue)")
            Text("Tx Fee: \(NSDecimalNumber(decimal: roundDecimal(amount: txInfo.fees)).stringValue)")
            if txInfo.fromAddress == user.walletAddress {
                Text("From: My Wallet")
            } else {
                Text("From: \(txInfo.fromAddress)")
            }
            
            if txInfo.toAddress == user.walletAddress {
                Text("To: My Wallet")
            } else {
                Text("To: \(txInfo.toAddress)")
            }
        }
        .font(.custom("MontserratAlternates-Regular", size: 20))
        .foregroundColor(Color(white: 0.342))
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25.0).fill(LinearGradient(gradient: Gradient(colors: [Color("Accent2"), Color("Accent")]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
        )
        
    }
}

extension WalletTransactionView {
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    func roundDecimal(amount: Decimal) -> Decimal {
        var rounded = Decimal()
        var decimalAmount = NSDecimalNumber(decimal: amount).decimalValue
        // find out how much ltc is needed to cover the bet
        NSDecimalRound(&rounded, &decimalAmount, 7, .bankers)
        return rounded
    }
}

struct WalletTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        WalletTransactionView(txInfo: WalletTransactionPreview(date: Date(), ltcAmount: 0.23, received: true, fromAddress: "asim", fees: 0.004, toAddress: "Kese"))
    }
}
