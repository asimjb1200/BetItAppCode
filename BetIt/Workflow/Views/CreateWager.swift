//
//  CreateWager.swift
//  BetIt
//
//  Created by Asim Brown on 8/9/21.
//

import SwiftUI

struct CreateWager: View {
    @EnvironmentObject private var user: UserModel
    @StateObject var viewModel = CreateWagerViewModel()
    let teams = TeamsMapper().Teams
    // private var testGames = [
//            DBGame(game_id: 2, sport: "BBall", home_team: 5, visitor_team: 4, game_begins: Date().addingTimeInterval(-604800), home_score: 20, season: 2020),
//            DBGame(game_id: 3, sport: "BBall", home_team: 6, visitor_team: 5, game_begins: Date(), home_score: 20, season: 2020),
//            DBGame(game_id: 4, sport: "BBall", home_team: 7, visitor_team: 6, game_begins: Date(), home_score: 20, season: 2020),
//            DBGame(game_id: 5, sport: "BBall", home_team: 8, visitor_team: 7, game_begins: Date(), home_score: 20, season: 2020),
//            DBGame(game_id: 6, sport: "BBall", home_team: 9, visitor_team: 8, game_begins: Date(), home_score: 20, season: 2020)
//        ]
    
    var body: some View {
        VStack(alignment: .leading) {
            DatePicker("Game Date: ",  selection: $viewModel.selectedDate, in: viewModel.range, displayedComponents: .date)
                .padding(.bottom, 20.0)
                .onChange(of: viewModel.selectedDate, perform: { chosenDate in
                    viewModel.loadGames(date: chosenDate, token: user.accessToken)
                })
            
            Picker("Which Game? ", selection: $viewModel.selectedGame) {
                ForEach(viewModel.games, id: \.self) {
                    Text("\(teams[$0.home_team] ?? "N/A") vs. \(teams[$0.visitor_team] ?? "N/A")")
                }
            }
            .padding(.vertical, 20.0)
            .pickerStyle(MenuPickerStyle())
            
            Text("Selected Game: \(teams[viewModel.selectedGame.home_team] ?? "not found") vs. \(teams[viewModel.selectedGame.visitor_team] ?? "not found")")
                .padding(.vertical)
                
            Text("Game Time: \(viewModel.dateToString)")
                .padding(.vertical)
            
            Text("Wager Amount:")
                .padding(.top, 20.0)
            TextField("LTC", text: $viewModel.wagerAmount)
                .padding(.bottom)
                .keyboardType(.numberPad)
            
            Button("Place Wager") {
                print("Wager Placed")
            }
            .padding(.vertical)
        }
        .onAppear() {
            viewModel.loadGames(date: viewModel.selectedDate, token: user.accessToken)
        }
    }
}

struct CreateWager_Previews: PreviewProvider {
    static var previews: some View {
        CreateWager()
    }
}
