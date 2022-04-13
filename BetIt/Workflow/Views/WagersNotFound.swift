//
//  WagersNotFound.swift
//  BetIt
//
//  Created by Asim Brown on 6/25/21.
//

import SwiftUI

struct WagersNotFound: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("No Active Wagers On This Game")
                    .bold()
                    .font(.custom("MontserratAlternates-Regular", size: 20))
                    .foregroundColor(.gray)
                
                Text("Be the first to create one!")
                    .bold()
                    .font(.custom("MontserratAlternates-Regular", size: 20))
                    .foregroundColor(.gray)
                
                NavigationLink(destination: CreateWager()) {
                    Text("Create a New Wager")
                    .foregroundColor(Color("Accent2"))
                }.accentColor(Color("Accent2"))
            }
        }
    }
}

struct WagersNotFound_Previews: PreviewProvider {
    static var previews: some View {
        WagersNotFound()
    }
}
