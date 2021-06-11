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
    var body: some View {
        let faderAddress = getUserWalletAddress()
        VStack(alignment: .leading) {
            Text("You will be betting against: " +  (teams[wager.bettor_chosen_team] ?? "Reload"))
            Text("Wager Amount: \(wager.game_id) LTC")
            Text("Amount in USD: $25")
            Text("Your Wallet Address: \n\(faderAddress)")
            
        }.padding().background(
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).fill(Color("Accent"))
        ).font(.custom("Roboto-Light", size: 20))
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
