//
//  WalletDetailsView.swift
//  BetIt
//
//  Created by Asim Brown on 7/7/21.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct WalletDetailsView: View {
    @State private var transferAddr: String = ""
    @StateObject var viewModel: WalletDetailsViewModel = WalletDetailsViewModel()
    @EnvironmentObject private var user: UserModel
    
    
    let qrGen: WalletQRGenerator = WalletQRGenerator()
    
    var body: some View {
        let davysGray = Color(white: 0.342)
        VStack {
            Text("Deposit Crypto:")
                .font(.custom("MontserratAlternates-Regular", size: 20))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, alignment: .leading)
            
                
            Text("\(user.walletAddress)")
                .font(.custom("MontserratAlternates-Regular", size: 25))
                .lineLimit(1)
                .padding(.all, 8.0)
                .background(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(Color("Accent2"))
                )
                .frame(height: /*@START_MENU_TOKEN@*/50/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            Image(uiImage: qrGen.generateQRCode(from: user.walletAddress))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Text("Balance: \(viewModel.ltcBalance)" as String)
                .font(.custom("MontserratAlternates-Regular", size: 20))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, alignment: .leading)
                .onAppear() {
                    viewModel.getLtcBalance(username: user.username, address: user.walletAddress, token: user.accessToken)
                }

            Text("\(viewModel.ltcBalance) LTC ≈ $\(viewModel.dollarBalance)" as String)
                .padding()
                .font(.custom("MontserratAlternates-Regular", size: 35))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(Color("Accent2"))
                )
            
            Text("Transfer to Wallet Address:")
                .font(.custom("MontserratAlternates-Regular", size: 20))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, alignment: .leading)
            
            TextField("Transfer Address", text: $transferAddr)
                .foregroundColor(Color("Accent2"))
                .frame(height: 50, alignment: .leading)
                .padding([.leading])
                .background(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(davysGray)
                )
        }
    }
}

struct WalletDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        WalletDetailsView()
    }
}
