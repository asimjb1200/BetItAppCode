//
//  UpcomingGamesViewModel.swift
//  BetIt
//
//  Created by Asim Brown on 7/8/21.
//

import Foundation

final class UpcomingGamesViewModel: ObservableObject {
    @Published var upcomingGames = [DBGame]()
    @Published var gameScheduleDate = Date()
    @Published var gamesAvailable = true
    let gameService: GameService = .shared
    
    func getGamesSchedule() {
        gameService.getUpcomingGames(completion: { (games) in
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
    
    func dateFormatting(date: Date) -> String {
        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "MM/dd/YY"
        
        // Convert Date to String
        return dateFormatter.string(from: date)
    }
    
    func getGamesByDate(date: Date = Date(), token: String, selectedDate: Date) {
        gameService.getGamesByDate(token: token, date: selectedDate, completion: { (todaysGames) in
            switch todaysGames {
            case .success(let scheduleToday):
                if scheduleToday.isEmpty {
                    DispatchQueue.main.async {
                        self.gamesAvailable = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.gamesAvailable = true
                        self.upcomingGames = scheduleToday
                    }
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
