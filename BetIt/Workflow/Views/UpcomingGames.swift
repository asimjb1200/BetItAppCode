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
    
    let pastDays = Date().addingTimeInterval(-604800)
    
    // add 7 days to the current date
    let range = Date() ... Date().addingTimeInterval(604800)
    
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
                    viewModel.getGamesByDate(token: user.accessToken, selectedDate: chosenDate, user: user)
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
                        viewModel.getGamesByDate(token: user.accessToken, selectedDate: viewModel.gameScheduleDate, user: user)
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
