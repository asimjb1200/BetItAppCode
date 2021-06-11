//
//  UpcomingGames.swift
//  BetIt
//
//  Created by Asim Brown on 5/29/21.
//

import SwiftUI

struct UpcomingGames: View {
    @State private var upcomingGames = [DBGame]()
    @State private var gameScheduleDate = Date()
    
    let pastDays = Date().addingTimeInterval(-604800)
    
    // add 7 days to the current date
//    let range = Date() ... Date().addingTimeInterval(604800)
    let range = Date().addingTimeInterval(-604800) ... Date().addingTimeInterval(604800)
    
    let layout = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        VStack{
            DatePicker("Scheduled Games", selection: $gameScheduleDate, in: range, displayedComponents: .date)
                .onChange(of: gameScheduleDate,perform: { chosenDate in
                    // when the user picks a new date send it to the api to get games on that date
                    self.getGamesByDate(date: chosenDate)
                })
        ScrollView {
            LazyVGrid(columns: layout, spacing: 20) {
                ForEach(upcomingGames, id: \.self) { game in
                    GamePreview(currentGame: game)
                }
            }
        }.onAppear() {
            self.getGamesByDate(date: gameScheduleDate)
        }
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
    
    func getGamesByDate(date: Date = Date()) {
        GameService().getGamesByDate(date: date, completion: { (todaysGames) in
            switch todaysGames {
                case .success(let scheduleToday):
                    DispatchQueue.main.async {
                        self.upcomingGames = scheduleToday
                    }
                case .failure(let err):
                    print(err)
            }
        })
    }
    
    func getTodaysDate() -> Date {
        // grab today's date
        let today = Date()
        return today
    }
}

struct UpcomingGames_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingGames()
    }
}
