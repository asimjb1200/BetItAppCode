//
//  GamePreview.swift
//  BetIt
//
//  Created by Asim Brown on 5/29/21.
//

import SwiftUI

struct GamePreview: View {
    var currentGame: DBGame
    @State private var showDetails = false
    
    let Teams: [UInt8: String] = [
        1: "ATL",
        2: "BOS",
        3: "BKN",
        4: "CHA",
        5: "CHI",
        6: "CLE",
        7: "DAL",
        8: "DEN",
        9: "DET",
        10: "GSW",
        11: "HOU",
        12: "IND",
        13: "LAC",
        14: "LAL",
        15: "MEM",
        16: "MIA",
        17: "MIL",
        18: "MIN",
        19: "NOP",
        20: "NYK",
        21: "OKC",
        22: "ORL",
        23: "PHI",
        24: "PHX",
        25: "POR",
        26: "SAC",
        27: "SAS",
        28: "TOR",
        29: "UTA",
        30: "WAS"
    ]

    var body: some View {
        Button(action: {
            showDetails.toggle()
        }, label: {
            VStack(alignment: .center, spacing: 0.0) {
                Text(self.Teams[currentGame.home_team] ?? "Retry Request")
                    .font(.custom("Roboto-Medium", size: 30))
                    .foregroundColor(Color("Accent"))
                    .multilineTextAlignment(.center)
                
                Text("vs.")
                    .foregroundColor(Color("Accent"))
                
                Text(self.Teams[currentGame.visitor_team] ?? "Retry Request")
                    .font(.custom("Roboto-Medium", size: 30))
                    .foregroundColor(Color("Accent"))
                    .multilineTextAlignment(.center)
                Text("7:30pm ET")
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(Color("Accent"))
                .font(.custom("Roboto-Medium", size: 20))
            }
            .background(RoundedRectangle(cornerRadius: 25)
                            .fill(Color.gray)
                            )
        }).sheet(isPresented: $showDetails, content: {
            GameAndWagersView(selectedGame: currentGame)
        })
    }
}

struct GamePreview_Previews: PreviewProvider {
    static var previews: some View {
        GamePreview(currentGame: DBGame(game_id: 5, sport: "basketball", home_team: 6, visitor_team: 8, game_begins: Date(), season: 2019))
    }
}
