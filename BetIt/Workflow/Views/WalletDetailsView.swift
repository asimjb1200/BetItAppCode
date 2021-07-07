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
    let qrGen: WalletQRGenerator = WalletQRGenerator()
    
    var body: some View {
        let davysGray = Color(white: 0.342)
        VStack {
            Text("Deposit Crypto:")
                .font(.custom("MontserratAlternates-Regular", size: 20))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, alignment: .leading)
            
                
            Text("adlfjhnaouidfbapdjfnaxcxapsdbxxophadopfadbfp")
                .font(.custom("MontserratAlternates-Regular", size: 25))
                .lineLimit(1)
                .padding(.all, 8.0)
                .background(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(Color("Accent2"))
                )
                .frame(width: .infinity, height: /*@START_MENU_TOKEN@*/50/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            Image(uiImage: qrGen.generateQRCode(from: "adlfjhnaouidfbapdjfnaxcxapsdbxxophadopfadbfp"))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Text("Balance:")
                .font(.custom("MontserratAlternates-Regular", size: 20))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, alignment: .leading)

            Text("3 LTC ≈ $400")
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
                .frame(width: .infinity, height: 50, alignment: .leading)
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
