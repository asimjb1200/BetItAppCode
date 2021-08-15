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
    
    var body: some View {
        VStack(alignment: .leading) {
            DatePicker("Game Date: ",  selection: $viewModel.selectedDate, in: viewModel.range, displayedComponents: .date)
                .padding(.bottom, 20.0)
                .onChange(of: viewModel.selectedDate, perform: { chosenDate in
                    viewModel.loadGames(date: chosenDate, token: user.accessToken)
                })
            if viewModel.games.isEmpty {
                Text("No games are being played on that date. Pick another.")
            } else {
                
                Picker("Which Game? ", selection: $viewModel.selectedGame) {
                    ForEach(viewModel.games, id: \.self) {
                        Text("\(teams[$0.home_team] ?? "Try Another Date") vs. \(teams[$0.visitor_team] ?? "Try Another Date")")
                    }
                }
                .padding(.vertical, 20.0)
                .pickerStyle(MenuPickerStyle())
                
                Text("Selected Game: \(teams[viewModel.selectedGame.home_team] ?? "Try Another Date") vs. \(teams[viewModel.selectedGame.visitor_team] ?? "Try Another Date")")
                    .padding(.vertical)
                    
                Text("Game Time: \(viewModel.dateToString)")
                    .padding(.vertical)
                
                Text("I'm betting on: \(teams[viewModel.selectedTeam]!) to win.")
                Picker("I'm betting on: ", selection: $viewModel.selectedTeam) {
                    Text("\(teams[viewModel.selectedGame.visitor_team]!)").tag(viewModel.selectedGame.visitor_team)
                    Text("\(teams[viewModel.selectedGame.home_team]!)").tag(viewModel.selectedGame.home_team)
                }
                .foregroundColor(Color("Accent2"))
                .pickerStyle(SegmentedPickerStyle())
                
                Text("Wager Amount:")
                    .padding(.top, 20.0)
                TextField("LTC", text: $viewModel.wagerAmount)
                    .padding(.bottom)
                    .keyboardType(.numberPad)
                
                Button("Place Wager") {
                    viewModel.placeBet(token: user.accessToken, bettor: user.walletAddress)
                }
                .padding(.vertical)
            }
        }.onAppear() {
            if viewModel.games.isEmpty {
                viewModel.loadGames(date: viewModel.selectedDate, token: user.accessToken)
            }
        }.alert(isPresented: $viewModel.showAlert) {
            switch viewModel.wagerCreated {
                case true:
                    return Alert(title: Text("Success"), message: Text("Your wager was created and entered into the pool."), dismissButton: .default(Text("OK")))
                
                case false:
                 return Alert(title: Text("Something went wrong"), message: Text("Your wager couldn't be created. Try again."), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct CreateWager_Previews: PreviewProvider {
    static var previews: some View {
        CreateWager()
    }
}
