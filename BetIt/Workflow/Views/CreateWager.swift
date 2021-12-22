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
        VStack {
                if viewModel.canWager {
                    DatePicker("Game Date: ",  selection: $viewModel.selectedDate, in: viewModel.range, displayedComponents: .date)
                        .accentColor(Color("Accent2"))
                        .font(.custom("MontserratAlternates-Regular", size: 15))
                        .onChange(of: viewModel.selectedDate, perform: { chosenDate in
                            viewModel.loadGames(date: chosenDate, token: user.accessToken, user: user)
                        })
                        .padding(.bottom)
                        
                        
                    if viewModel.games.isEmpty {
                        Text("Either no games are being played on that date, or they are too close to starting. Pick another date.").font(.custom("MontserratAlternates-Regular", size: 20))
                    } else {
                        Spacer()
                        Group{
                            Picker("", selection: $viewModel.selectedGame) {
                                ForEach(viewModel.games, id: \.self) {
                                    Text("\(teams[$0.home_team] ?? "Try Another Date") vs. \(teams[$0.visitor_team] ?? "Try Another Date")")
                                    .font(.custom("MontserratAlternates-Regular", size: 15))
                                }
                            }
                            .padding(.vertical)
                            .font(.custom("MontserratAlternates-Regular", size: 15))
                            .foregroundColor(Color("Accent2"))
                            .pickerStyle(MenuPickerStyle())
                            
                            if viewModel.selectedGame.game_id == 0 {
                                Text("Pick A Game to Bet On Above!").font(.custom("MontserratAlternates-Regular", size: 15))
                            }
                                
                            Text("Game Time: \(viewModel.dateToString)")
                                .font(.custom("MontserratAlternates-Regular", size: 15))
                                .padding(.vertical)
                            Spacer()
                            
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
                        }
                        
                        Spacer()
                        Group{
                            Text("\(NSDecimalNumber(decimal: viewModel.calcLtcAmount(wagerAmountInDollars: viewModel.wagerAmount)).stringValue) LTC")
                                .font(.custom("MontserratAlternates-Regular", size: 20.0))
                                .padding([.top, .leading, .bottom])
                                .alert(isPresented: $viewModel.showAlert) {
                                    if viewModel.notEnoughCrypto {
                                        return Alert(title: Text("Insufficient Crypto"), message: Text("You don't have enough crytpo in your wallet to place this bet."), dismissButton: .default(Text("OK")))
                                    } else {
                                        switch viewModel.wagerCreated {
                                            case true:
                                                return Alert(title: Text("Success"), message: Text("Your wager was created and entered into the pool."), dismissButton: .default(Text("OK")))

                                            case false:
                                                return Alert(title: Text("Something went wrong"), message: Text("Your wager couldn't be created. Try again."), dismissButton: .default(Text("OK")))
                                        }
                                    }
                                }
                            HStack {
                                Text("$")
                                    .font(.custom("MontserratAlternates-Regular", size: 30.0))
                                    .padding(.leading)
                                    
                                TextField("USD", text: $viewModel.wagerAmount)
                                    .font(.custom("MontserratAlternates-Regular", size: 20.0))
                                    .padding([.top, .leading, .bottom])
                                    .background(
                                        RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                                            .fill(
                                                Color(hue: 1.0, saturation: 0.0, brightness: 0.694, opacity: 0.763).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                                            )
                                    )
                                    .keyboardType(.numberPad)
                            }
                        
                            Spacer()
                            Button("Place Wager") {
                                guard
                                    !viewModel.wagerAmount.isEmpty,
                                    viewModel.wagerAmount != "0" && viewModel.wagerAmount != "0.0"
                                else {
                                    return
                                }
                                // check that they didn't enter a number below 0
                                let tempNum = Decimal(string: viewModel.wagerAmount) ?? 0
                                guard tempNum > 0 else {
                                    return
                                }
                                viewModel.checkWalletBalance(address: user.walletAddress, username: user.username, token: user.accessToken, user: user)
                            }
                            .font(.custom("MontserratAlternates-Regular", size: 15.0))
                            .padding(.all)
                            .disabled(viewModel.notEnoughCrypto)
                            .background(
                                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).fill(Color("Accent2"))
                            )
                            .foregroundColor(.black)
                            .padding(.bottom)
                        }
                    }
                } else {
                    Text("You can not have more than 2 active wagers at a time, please wait until one of your wagers concludes. Or cancel one.")
                }
        }
        .frame(maxHeight: .infinity)
        .onAppear() {
            viewModel.checkWagerCount(bettor: user.walletAddress, token: user.accessToken, user: user)
            viewModel.getCurrLtcPrice()
            if viewModel.canWager {
                if viewModel.games.isEmpty {
                    viewModel.loadGames(date: viewModel.selectedDate, token: user.accessToken, user: user)
                }
            }
        }.foregroundColor(Color("Accent2"))
    }
}

struct CreateWager_Previews: PreviewProvider {
    static var previews: some View {
        CreateWager()
    }
}
