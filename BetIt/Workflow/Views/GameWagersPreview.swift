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
        if !wager.is_active {
            VStack {
                NavigationLink( destination: WagerDetailsView(wager: wager),isActive: $showWagerDetails) {EmptyView()}.hidden()
                Button(action: {
                    self.showWagerDetails = true
                }, label: {
                    Text("\(NSDecimalNumber(decimal: wager.wager_amount).stringValue) Ltc \n Bettor's Pick: \(teams[wager.bettor_chosen_team] ?? "can't find team")")
                        .multilineTextAlignment(.center)
                        .padding(.all)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.custom("MontserratAlternates-Regular", size: 25))
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [bgColor, fgColor]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                    }
                )
            }.padding([.top, .bottom])
        }
    }
}

struct GameWagersPreview_Previews: PreviewProvider {
    static var previews: some View {
        GameWagersPreview(wager: WagerModel(id: 5, bettor: "Asim", wager_amount: 5, game_id: 6, is_active: false, bettor_chosen_team: 8))
    }
}
