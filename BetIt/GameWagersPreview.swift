//
//  GameWagersView.swift
//  BetIt
//
//  Created by Asim Brown on 6/8/21.
//

import SwiftUI

struct GameWagersPreview: View {
    @ObservedObject var wager: WagerModel
    @State var showWagerDetails: Bool = false
    var body: some View {
        let bgColor = wager.is_active ? Color.gray : Color("Accent")
        let fgColor = wager.is_active ? Color("Accent") : Color.gray
            NavigationLink(
                destination: WagerDetailsView(wager: wager),
                isActive: $showWagerDetails,
                label: {
                    Button(action: {
                            self.showWagerDetails.toggle()
                        }, label: {
                            Text("\(wager.wager_amount) Ltc \n Bettor's Pick: \(wager.bettor_chosen_team)")
                                .multilineTextAlignment(.center)
                                .padding(.all)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.custom("Roboto-Medium", size: 25))
                                .foregroundColor(fgColor)
                                .background(
                                    Capsule().fill(bgColor)
                                )
                        }
                    )
                }
            )
    }
}

struct GameWagersPreview_Previews: PreviewProvider {
    static var previews: some View {
        GameWagersPreview(wager: WagerModel(id: 5, bettor: "Asim", wager_amount: 5, game_id: 6, is_active: true, bettor_chosen_team: 8))
    }
}
