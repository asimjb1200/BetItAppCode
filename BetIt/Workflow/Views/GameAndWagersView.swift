//
//  GameAndWagersView.swift
//  BetIt
//
//  Created by Asim Brown on 6/8/21.
//

import SwiftUI

struct GameAndWagersView: View {
    @ObservedObject private var wagersOnGame: GameWagers = .shared
    @EnvironmentObject private var userManager: UserManager
    @State private var wagersNotFound: Bool = false
    var selectedGame: DBGame
    private let Teams: [UInt8: String] = TeamsMapper().Teams
    
    var body: some View {
        let gameHeader = "\(Teams[selectedGame.home_team]!) vs. \(Teams[selectedGame.visitor_team]!)"
        
        NavigationView {
            if wagersNotFound {
                WagersNotFound()
                .navigationTitle(gameHeader)
            } else {
                List(wagersOnGame.wagers) { wager in
                    GameWagersPreview(wager: wager)
                }.onAppear() {
                    self.getWagersByGameId()
                }.navigationTitle(gameHeader)
            }
        }
    }
}

extension GameAndWagersView {
    func getWagersByGameId() {
        guard
            let user = userManager.user
        else
            { return }
        WagerService().getWagersForGameId(token: user.accessToken, gameId: selectedGame.game_id, completion: { (wagers) in
            switch wagers {
            case .success(let gameWagers):
                if gameWagers.isEmpty {
                    self.wagersNotFound = true
                } else {
                    self.wagersNotFound = false
                    DispatchQueue.main.async {
                        self.wagersOnGame.wagers = gameWagers
                    }
                }
            case .failure(let err):
                print("error occurred: \(err)")
            }
        })
    }
}

struct GameAndWagersView_Previews: PreviewProvider {
    static var previews: some View {
        GameAndWagersView(selectedGame: DBGame(game_id: 5, sport: "bball", home_team: 5, visitor_team: 9, game_begins: Date(), season: 2019))
    }
}
