//
//  UpcomingGames.swift
//  BetIt
//
//  Created by Asim Brown on 5/29/21.
//

import SwiftUI

struct UpcomingGames: View {
    @StateObject private var viewModel: UpcomingGamesViewModel = UpcomingGamesViewModel()
    @EnvironmentObject var user: UserModel
//    private var testGames = [
//        DBGame(game_id: 2, sport: "BBall", home_team: 5, visitor_team: 4, game_begins: Date(), home_score: 20, season: 2020),
//        DBGame(game_id: 3, sport: "BBall", home_team: 6, visitor_team: 5, game_begins: Date(), home_score: 20, season: 2020),
//        DBGame(game_id: 4, sport: "BBall", home_team: 7, visitor_team: 6, game_begins: Date(), home_score: 20, season: 2020),
//        DBGame(game_id: 5, sport: "BBall", home_team: 8, visitor_team: 7, game_begins: Date(), home_score: 20, season: 2020),
//        DBGame(game_id: 6, sport: "BBall", home_team: 9, visitor_team: 8, game_begins: Date(), home_score: 20, season: 2020)
//    ]
    
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
            DatePicker("Scheduled Games", selection: $viewModel.gameScheduleDate, in: range, displayedComponents: .date)
                .padding(.bottom)
                .accentColor(accentColor)
                .onChange(of: viewModel.gameScheduleDate, perform: { chosenDate in
                    // when the user picks a new date send it to the api to get games on that date
                    viewModel.getGamesByDate(token: user.accessToken, selectedDate: chosenDate)
                })
            
            if viewModel.gamesAvailable {
                ScrollView {
                    LazyVGrid(columns: layout, spacing: 10) {
                        ForEach(viewModel.upcomingGames, id: \.self) { game in
                            GamePreview(currentGame: game)
                        }
                    }
                }.onAppear() {
                    if viewModel.upcomingGames.isEmpty {
                        viewModel.getGamesByDate(token: user.accessToken, selectedDate: viewModel.gameScheduleDate)
                    }
                }
            } else {
                GamesNotFound(date: viewModel.dateFormatting(date: viewModel.gameScheduleDate))
            }
        }
    }
}

struct UpcomingGames_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingGames()
    }
}
