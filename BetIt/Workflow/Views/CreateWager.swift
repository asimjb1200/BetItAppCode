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
    
    init() {
        // custom setting the segmented picker's colors in normal and selected states
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color("Accent2"))
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color("Accent2"))], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            DatePicker("Game Date: ",  selection: $viewModel.selectedDate, in: viewModel.range, displayedComponents: .date)
                .font(.custom("MontserratAlternates-Regular", size: 15))
                .padding(.bottom, 20.0)
                .onChange(of: viewModel.selectedDate, perform: { chosenDate in
                    viewModel.loadGames(date: chosenDate, token: user.accessToken)
                })
            if viewModel.games.isEmpty {
                Text("No games are being played on that date. Pick another.").font(.custom("MontserratAlternates-Regular", size: 15))
            } else {
                Text("Which Game?")
                    .font(.custom("MontserratAlternates-Regular", size: 15))
                Picker("", selection: $viewModel.selectedGame) {
                    ForEach(viewModel.games, id: \.self) {
                        Text("\(teams[$0.home_team] ?? "Try Another Date") vs. \(teams[$0.visitor_team] ?? "Try Another Date")")
                        .font(.custom("MontserratAlternates-Regular", size: 15))
                    }
                }
                .font(.custom("MontserratAlternates-Regular", size: 15))
                .padding(.bottom, 20.0)
                    
                Text("Game Time: \(viewModel.dateToString)")
                    .font(.custom("MontserratAlternates-Regular", size: 15))
                    .padding(.vertical)
                
                if viewModel.selectedTeam == 0 {
                    Text("Select a team").font(.custom("MontserratAlternates-Regular", size: 15))
                } else {
                    Text("I'm betting on: \(teams[viewModel.selectedTeam]!) to win.").font(.custom("MontserratAlternates-Regular", size: 15))
                }
                
                Picker("", selection: $viewModel.selectedTeam) {
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
                .font(.custom("MontserratAlternates-Regular", size: 10))
                .padding(.all)
                .background(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).fill(Color.gray)
                )
                .foregroundColor(Color("Accent2"))
            }
        }.onAppear() {
            // TODO: make sure the user doesn't already have more than 2 bets in the db already
            
            
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
