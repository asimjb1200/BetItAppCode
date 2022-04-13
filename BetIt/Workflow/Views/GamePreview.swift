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
        let accent1 = Color("Accent")
        let accent2 = Color("Accent2")
        Button(action: {
            showDetails.toggle()
        }, label: {
            VStack(alignment: .center, spacing: 0.0) {
                Text(teams[currentGame.home_team] ?? "Retry Request")
                    .font(.custom("MontserratAlternates-Regular", size: 28))
                    .foregroundColor(davysGray)
                    .multilineTextAlignment(.center)
                
                Text("\(formatDate(date: currentGame.game_begins))")
                    .font(.custom("MontserratAlternates-Regular", size: 14))
                    .foregroundColor(davysGray)
                
                Text(teams[currentGame.visitor_team] ?? "Retry Request")
                    .font(.custom("MontserratAlternates-Regular", size: 28))
                    .foregroundColor(davysGray)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(width: 150, height: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .background(
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [accent1, accent2]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }).sheet(isPresented: $showDetails, content: {
            GameAndWagersView(selectedGame: currentGame)
        })
    }
}

extension GamePreview {
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: date)
    }
}

struct GamePreview_Previews: PreviewProvider {
    static var previews: some View {
        GamePreview(currentGame: DBGame(game_id: 5, sport: "basketball", home_team: 6, visitor_team: 8, game_begins: Date(), season: 2019))
    }
}
