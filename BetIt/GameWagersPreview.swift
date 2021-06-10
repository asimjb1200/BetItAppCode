//
//  GameWagersView.swift
//  BetIt
//
//  Created by Asim Brown on 6/8/21.
//

import SwiftUI

struct GameWagersPreview: View {
    @ObservedObject var wager: WagerModel
    var body: some View {
        VStack {
            Text("\(wager.wager_amount) Ltc \n Bettor's Pick: \(wager.bettor_chosen_team)")
                .multilineTextAlignment(.center)
                .padding(.all)
                .fixedSize(horizontal: false, vertical: true)
                .font(.custom("Roboto-Medium", size: 25))
                .foregroundColor(Color.gray)
                .background(
                    Capsule()
                        .fill(Color("Accent"))
                )
            
            Button(action: {
                self.wager.wager_amount = 10
                        }) {
                            Text("change bet amount")
                        }
        }
    }
}

struct GameWagersPreview_Previews: PreviewProvider {
    static var previews: some View {
        Text("k")
//        GameWagersPreview(wager: WagerModel(id: 5, bettor: "Asim", wager_amount: 5, game_id: 6, is_active: true, bettor_chosen_team: 8, escrow_address: "test"))
    }
}
