//
//  WalletDetailsView.swift
//  BetIt
//
//  Created by Asim Brown on 7/7/21.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct WalletDetailsView: View {
    @StateObject var viewModel: WalletDetailsViewModel = WalletDetailsViewModel()
    @EnvironmentObject private var user: UserModel
    
    let qrGen: WalletQRGenerator = WalletQRGenerator()
    
    var body: some View {
        let davysGray = Color(white: 0.342)
        ScrollView {
            //Spacer().frame(height: 50.0)
            Text("Deposit Crypto:")
                .font(.custom("MontserratAlternates-Regular", size: 20))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
            
                
            Text("\(user.walletAddress)")
                .font(.custom("MontserratAlternates-Regular", size: 20))
                .padding(.all, 8.0)
                .background(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(Color("Accent2"))
                )
                .frame(height: 100, alignment: .leading)
            
            Image(uiImage: qrGen.generateQRCode(from: user.walletAddress))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            Text("Balance: \(String(format: "%.7f", viewModel.ltcBalance)) LTC")
                .font(.custom("MontserratAlternates-Regular", size: 20))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, alignment: .leading)
                .onAppear() {
                    viewModel.getLtcBalance(username: user.username, address: user.walletAddress, token: user.accessToken)
                    viewModel.getCurrLtcPrice()
                }
                .alert(isPresented: $viewModel.cryptoTiedUpInWagers) {
                    Alert(title: Text("Crypto Tied To Wagers"), message: Text("You have too much crypto tied up in wagers. Cancel a wager before trying to withdraw."), dismissButton: .default((Text("OK"))))
                }

            Text("$\(String(format: "%.2f", viewModel.dollarBalance)) USD")
                .padding()
                .font(.custom("MontserratAlternates-Regular", size: 35))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(Color("Accent2"))
                )
                .alert(isPresented: $viewModel.showEmptyAmountAlert) {
                    Alert(title: Text("Invalid Transfer Amount"), message: Text("Enter a valid dollar amount and try again."), dismissButton: .default(Text("OK")))
                }
            
            Text("Transfer to Wallet Address:")
                .font(.custom("MontserratAlternates-Regular", size: 20))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, alignment: .leading)
            
            TextField("Transfer Address", text: $viewModel.transferAddr)
                .foregroundColor(Color("Accent2"))
                .frame(height: 50, alignment: .leading)
                .padding([.leading])
                .background(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(davysGray)
                )
                .alert(isPresented: $viewModel.showEmptyAddressAlert) {
                    Alert(title: Text("Invalid Transfer Address"), message: Text("Check the address and try again."), dismissButton: .default(Text("OK")))
                }
            
            HStack {
                Text("\(NSDecimalNumber(decimal: viewModel.calcLtcAmount(wagerAmountInDollars: viewModel.transferAmount)).stringValue) LTC").font(.custom("MontserratAlternates-Regular", size: 20)).padding(.trailing)
                
                Text("$:").font(.custom("MontserratAlternates-Regular", size: 20))
                
                TextField("Transfer Amount", text: $viewModel.transferAmount)
                    .foregroundColor(Color("Accent2"))
                    .frame(height: 50, alignment: .leading)
                    .padding([.leading])
                    .keyboardType(.decimalPad)
                    .background(
                        RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                            .fill(davysGray)
                    )
            }
            .padding([.leading])


            Button("Send to Address") {
                guard
                    !viewModel.transferAddr.isEmpty
                else {
                    viewModel.showEmptyAddressAlert.toggle()
                    return
                }
                
                guard
                    !viewModel.transferAmount.isEmpty
                else {
                    viewModel.showEmptyAmountAlert.toggle()
                    return
                }
                
                viewModel.checkForLtcTiedUpInWagers(token: user.accessToken, walletAddr: user.walletAddress)
            }
            .foregroundColor(Color("Accent2"))
            .alert(isPresented: $viewModel.showAlert) {
                if viewModel.txStarted {
                    return Alert(title: Text("Transaction message"), message: Text("Your transfer has began. Your crypto will be moved shortly"), dismissButton: .default(Text("OK")))
                } else {
                    return Alert(title: Text("Transaction Message"), message: Text("There was a problem starting your transaction. Check the address, make sure you have enough crypto and then try again."), dismissButton: .default(Text("OK")))
                }
            }
            
            Spacer()
        }
        .onTapGesture {
            self.hideKeyboard()
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct WalletDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        WalletDetailsView()
    }
}
