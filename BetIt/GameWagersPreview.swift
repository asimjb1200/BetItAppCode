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
    let teams = TeamsMapper().Teams
    var body: some View {
        let davysGray = Color(white: 0.342)
        let bgColor = wager.is_active ? davysGray : Color("Accent2")
        let fgColor = wager.is_active ? Color("Accent2") : davysGray
            NavigationLink(
                destination: WagerDetailsView(wager: wager),
                isActive: $showWagerDetails,
                label: {
                    Button(action: {
                            self.showWagerDetails.toggle()
                        }, label: {
                            Text("\(wager.wager_amount) Ltc \n Bettor's Pick: \(teams[wager.bettor_chosen_team] ?? "can't find team")")
                                .multilineTextAlignment(.center)
                                .padding(.all)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.custom("Roboto-Light", size: 25))
                                .foregroundColor(fgColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                                        .stroke(bgColor, lineWidth: 4)
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
