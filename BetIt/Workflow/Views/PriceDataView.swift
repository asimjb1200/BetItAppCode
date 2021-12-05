//
//  PriceDataView.swift
//  BetIt
//
//  Created by Asim Brown on 11/30/21.
//

import SwiftUI

struct PriceDataView: View {
    @ObservedObject var viewModel = PriceDataViewModel()
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color("Accent"), Color("Accent2")]), center: .center, startRadius: 100, endRadius: 470)
            VStack {
                Text("Current LTC Price: ").font(.custom("MontserratAlternates-SemiBold", size: 35)).foregroundColor(Color(white: 0.342))
                Text("\(viewModel.currentPrice)").font(.custom("MontserratAlternates-SemiBold", size: 35)).foregroundColor(Color(white: 0.342))
                Text("(Price data from Coinbase)").foregroundColor(Color(white: 0.342))
            }.onAppear() {
                viewModel.getLtcPrice()
            }
            
        }.edgesIgnoringSafeArea(.all)
    }
}

struct PriceDataView_Previews: PreviewProvider {
    static var previews: some View {
        PriceDataView()
    }
}
