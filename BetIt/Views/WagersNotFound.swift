//
//  WagersNotFound.swift
//  BetIt
//
//  Created by Asim Brown on 6/25/21.
//

import SwiftUI

struct WagersNotFound: View {
    var body: some View {
        ZStack {
            Image("wagerbot")
                .resizable()
                .scaledToFit()
            Text("Be the first to create one! Click the plus sign below and then spread the word!")
                .bold()
                .font(.custom("MontserratAlternates-Regular", size: 20))
                .foregroundColor(.gray)
                .offset(y: 175)
        }.frame(maxHeight: .infinity).edgesIgnoringSafeArea(.all)
    }
}

struct WagersNotFound_Previews: PreviewProvider {
    static var previews: some View {
        WagersNotFound()
    }
}
