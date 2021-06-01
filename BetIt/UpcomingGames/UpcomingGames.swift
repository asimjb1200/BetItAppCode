//
//  UpcomingGames.swift
//  BetIt
//
//  Created by Asim Brown on 5/29/21.
//

import SwiftUI

struct UpcomingGames: View {
    @State var upcomingGames = [DBGame]()
    
    var body: some View {
        HStack {
            List(upcomingGames, id: \.self) { game in
                GamePreview(homeTeam: game.home_team, awayTeam: game.visitor_team)
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
