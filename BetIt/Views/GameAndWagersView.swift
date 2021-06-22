//
//  GameAndWagersView.swift
//  BetIt
//
//  Created by Asim Brown on 6/8/21.
//

import SwiftUI

struct GameAndWagersView: View {
    @ObservedObject var wagersOnGame: GameWagers = .shared
    @EnvironmentObject var user: User
    var selectedGame: DBGame
    private let Teams: [UInt8: String] = TeamsMapper().Teams
    
    var body: some View {
        let gameHeader = "\(Teams[selectedGame.home_team]!) vs. \(Teams[selectedGame.visitor_team]!)"
        
        NavigationView {
            List(wagersOnGame.wagers) { wager in
                GameWagersPreview(wager: wager).transition(.slide)
            }.onAppear() {
                self.getWagersByGameId()
            }
            .navigationTitle(gameHeader)
        }
    }
}

extension GameAndWagersView {
    func getWagersByGameId() {
        WagerService().getWagersForGameId(token: user.access_token, gameId: selectedGame.game_id, completion: { (wagers) in
            switch wagers {
            case .success(let gameWagers):
                DispatchQueue.main.async {
                    self.wagersOnGame.wagers = gameWagers
                }
            case .failure(let err):
                print("error occurred: \(err)")
            }
        })
    }
}

struct GameAndWagersView_Previews: PreviewProvider {
    static var previews: some View {
        //        Text("hi")
        GameAndWagersView(selectedGame: DBGame(game_id: 5, sport: "bball", home_team: 5, visitor_team: 9, game_begins: Date(), season: 2019))
    }
}
