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
    @Published var userTokenExpired = false
    let gameService: GameService = .shared
    
    func dateFormatting(date: Date) -> String {
        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "MM/dd/YY"
        
        // Convert Date to String
        return dateFormatter.string(from: date)
    }
    
    func getGamesByDate(date: Date = Date(), token: String, selectedDate: Date, user: UserModel) {
        gameService.getGamesByDate(token: token, date: selectedDate, completion: {[weak self] (todaysGames) in
            switch todaysGames {
            case .success(let scheduleToday):
                if scheduleToday.dataForClient.isEmpty {
                    DispatchQueue.main.async {
                        self?.gamesAvailable = false
                        guard let
                                newAccessToken = scheduleToday.newAccessToken
                        else {
                            return // if newAccessToken is nil, the function will return and skip the code below
                        }
                        user.accessToken = newAccessToken
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.gamesAvailable = true
                        self?.upcomingGames = scheduleToday.dataForClient
                        guard let
                                newAccessToken = scheduleToday.newAccessToken
                        else {
                            return // if newAccessToken is nil, the function will return and skip the code below
                        }
                        user.accessToken = newAccessToken
                    }
                }
            case .failure(let err):
                if err == .tokenExpired {
                    DispatchQueue.main.async {
                        user.logUserOut()
                    }
                }
            }
        })
    }
    
    func getTodaysDate() -> Date {
        // grab today's date
        let today = Date()
        return today
    }
}
