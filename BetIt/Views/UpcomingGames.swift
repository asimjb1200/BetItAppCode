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
    @State private var gamesAvailable = true
    //    @EnvironmentObject var user: User
    @EnvironmentObject var userManager: UserManager
    private var testGames = [
        DBGame(game_id: 2, sport: "BBall", home_team: 5, visitor_team: 4, game_begins: Date(), home_score: 20, season: 2020),
        DBGame(game_id: 3, sport: "BBall", home_team: 6, visitor_team: 5, game_begins: Date(), home_score: 20, season: 2020),
        DBGame(game_id: 4, sport: "BBall", home_team: 7, visitor_team: 6, game_begins: Date(), home_score: 20, season: 2020),
        DBGame(game_id: 5, sport: "BBall", home_team: 8, visitor_team: 7, game_begins: Date(), home_score: 20, season: 2020),
        DBGame(game_id: 6, sport: "BBall", home_team: 9, visitor_team: 8, game_begins: Date(), home_score: 20, season: 2020)
    ]
    
    let pastDays = Date().addingTimeInterval(-604800)
    
    // add 7 days to the current date
    let range = Date() ... Date().addingTimeInterval(604800)
    //    let range = Date().addingTimeInterval(-1004800) ... Date().addingTimeInterval(604800)
    
    let layout = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    var body: some View {
        VStack{
            let accentColor = Color("Accent2")
            DatePicker("Scheduled Games", selection: $gameScheduleDate, in: range, displayedComponents: .date)
                .padding(.bottom)
                .accentColor(accentColor)
                .onChange(of: gameScheduleDate,perform: { chosenDate in
                    // when the user picks a new date send it to the api to get games on that date
                    self.getGamesByDate(token: userManager.user.access_token, date: chosenDate)
                })
            if gamesAvailable {
                ScrollView {
                    LazyVGrid(columns: layout, spacing: 10) {
                        ForEach(upcomingGames, id: \.self) { game in
                            GamePreview(currentGame: game)
                        }
                    }
                }.onAppear() {
                    self.getGamesByDate(token: userManager.user.access_token, date: gameScheduleDate)
                }
            } else {
                Text("No games available for this date.")
                    .bold()
                    .font(.custom("MontserratAlternates-Regular", size: 30))
                    .foregroundColor(Color("Accent2"))
                Text("Try another date.")
                    .font(.custom("MontserratAlternates-Thin", size: 20))
                
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
    
    func getGamesByDate(token: String, date: Date = Date()) {
        GameService().getGamesByDate(token: token, date: date, completion: { (todaysGames) in
            switch todaysGames {
            case .success(let scheduleToday):
                DispatchQueue.main.async {
                    print(scheduleToday)
                    if scheduleToday.isEmpty {
                        self.gamesAvailable = false
                    } else {
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

struct UpcomingGames_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingGames()
    }
}
