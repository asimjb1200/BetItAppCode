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
    let teams = TeamsMapper().Teams

    var body: some View {
        let davysGray = Color(white: 0.342)
        Button(action: {
            showDetails.toggle()
        }, label: {
            VStack(alignment: .center, spacing: 0.0) {
                Text(teams[currentGame.home_team] ?? "Retry Request")
                    .font(.custom("Roboto-Light", size: 30))
                    .foregroundColor(Color("Accent2"))
                    .multilineTextAlignment(.center)
                
                Text("vs.")
                    .foregroundColor(Color("Accent2"))
                
                Text(teams[currentGame.visitor_team] ?? "Retry Request")
                    .font(.custom("Roboto-Light", size: 30))
                    .foregroundColor(Color("Accent2"))
                    .multilineTextAlignment(.center)
                Text("7:30pm ET")
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(Color("Accent2"))
                .font(.custom("Roboto-Light", size: 20))
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                    .stroke(davysGray, lineWidth: 2)
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