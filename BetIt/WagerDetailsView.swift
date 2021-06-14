//
//  WagerDetailsView.swift
//  BetIt
//
//  Created by Asim Brown on 6/9/21.
//

import SwiftUI

struct WagerDetailsView: View {
    @ObservedObject var wager: WagerModel
    let teams = TeamsMapper().Teams
    let accentColor = Color("Accent2")
    let davysGray = Color(white: 0.342)
    
    var body: some View {
        var faderAddress = ""

        VStack(alignment: .leading) {
            Text("You will be betting against: " +  (teams[wager.bettor_chosen_team] ?? "Reload")).foregroundColor(accentColor)
            Text("Wager Amount: \(wager.game_id) LTC").foregroundColor(accentColor)
            Text("Amount in USD: $250").foregroundColor(accentColor)
            Button(action: {
                // TODO: Add logic to save the bet if the fader confirms
            }, label: {
                Text("Take this bet")
                    .padding()
                    .foregroundColor(accentColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                            .stroke(accentColor, lineWidth: 4)
                    )
            })
        }.padding().overlay(
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                .stroke(Color("Accent2"), lineWidth: 4)
        ).font(.custom("Roboto-Light", size: 20))
        .onAppear() {
            faderAddress = self.getUserWalletAddress()
        }
    }
}

extension WagerDetailsView {
    func getUserWalletAddress() -> String {
        return "UsersWalletAddress"
    }
}

struct WagerDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        WagerDetailsView(wager: WagerModel(id: 5, bettor: "Asim", wager_amount: 33, game_id: 23, is_active: true, bettor_chosen_team: 12))
    }
}
