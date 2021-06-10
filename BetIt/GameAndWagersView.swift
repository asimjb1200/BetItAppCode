//
//  GameAndWagersView.swift
//  BetIt
//
//  Created by Asim Brown on 6/8/21.
//

import SwiftUI

class GameWagers: ObservableObject {
    @Published var wagers: [WagerModel] = []
    
//    init(wagers: [WagerModel]) {
//        self.wagers = wagers
//    }
}

struct GameAndWagersView: View {
//    @State fileprivate var wagers = [Wager]()
    @ObservedObject var wagersOnGame: GameWagers = GameWagers()
    var selectedGame: DBGame
    private let Teams: [UInt8: String] = [
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
        VStack {
            Text("Matchup is \(Teams[selectedGame.home_team]!) vs. \(Teams[selectedGame.visitor_team]!)")
            ScrollView {
                LazyVStack {
                    ForEach(wagersOnGame.wagers) { wagerForGame in
                        GameWagersPreview(wager: wagerForGame)
                    }
                }
            }
        }.onAppear() {
            self.getWagersByGameId()
        }
    }
}

extension GameAndWagersView {
    func getWagersByGameId() {
        WagerService().getWagersForGameId(gameId: selectedGame.game_id, completion: { (wagers) in
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
        Text("hi")
//        GameAndWagersView(selectedGame: DBGame(game_id: 5, sport: "bball", home_team: 5, visitor_team: 9, game_begins: Date(), season: 2019))
    }
}
