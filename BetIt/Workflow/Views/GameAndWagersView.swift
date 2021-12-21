//
//  GameAndWagersView.swift
//  BetIt
//
//  Created by Asim Brown on 6/8/21.
//

import SwiftUI

struct GameAndWagersView: View {
    @StateObject private var viewModel: GameWagersViewModel = .shared
    @EnvironmentObject private var user: UserModel
    var selectedGame: DBGame
    private let Teams: [UInt8: String] = TeamsMapper().Teams
    
    var body: some View {
        let gameHeader = "\(Teams[selectedGame.home_team]!) vs. \(Teams[selectedGame.visitor_team]!)"
        NavigationView {
            if viewModel.wagers.isEmpty {
                WagersNotFound()
                    .navigationTitle(gameHeader)
            } else {
                ScrollView {
                    LazyVStack{
                        ForEach(viewModel.wagers) { wager in
                            GameWagersPreview(wager: wager)
                        }
                    }
                }.navigationTitle(gameHeader)
            }
        }.onAppear() {
            if viewModel.wagers.isEmpty {
                viewModel.getWagersByGameId(token: user.accessToken, gameId: selectedGame.game_id, user: user)
            }
        }
        .accentColor(Color("Accent2"))
    }
}

struct GameAndWagersView_Previews: PreviewProvider {
    static var previews: some View {
        GameAndWagersView(selectedGame: DBGame(game_id: 5, sport: "bball", home_team: 5, visitor_team: 9, game_begins: Date(), season: 2019))
    }
}
