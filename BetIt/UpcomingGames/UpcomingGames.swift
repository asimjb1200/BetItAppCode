//
//  UpcomingGames.swift
//  BetIt
//
//  Created by Asim Brown on 5/29/21.
//

import SwiftUI

struct UpcomingGames: View {
    @State var upcomingGames = [DBGame]()
    let layout = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: layout, spacing: 20) {
                ForEach(upcomingGames, id: \.self) { game in
                    GamePreview(homeTeam: game.home_team, awayTeam: game.visitor_team)
                }
            }
        }.onAppear() {
            getGamesSchedule()
        }
    }
}

extension UpcomingGames {
        func getGamesSchedule() {
            GameService().getUpcomingGames(completion: { (games) in
                switch games {
                case .success(let gameData):
                    DispatchQueue.main.async {
                        self.upcomingGames = gameData
                    }
                case .failure(let err):
                    print(err)
                }
            })
        }
}

struct UpcomingGames_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingGames()
    }
}
