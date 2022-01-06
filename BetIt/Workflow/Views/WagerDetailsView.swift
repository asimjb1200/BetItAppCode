//
//  WagerDetailsView.swift
//  BetIt
//
//  Created by Asim Brown on 6/9/21.
//

import SwiftUI

struct WagerDetailsView: View {
    @ObservedObject var wager: WagerModel
    @StateObject var viewModel: WagerDetailsViewModel = WagerDetailsViewModel()
    @EnvironmentObject var user: UserModel
    let teams = TeamsMapper().Teams
    let accentColor = Color("Accent2")
    let davysGray = Color(white: 0.342)
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Betting Against")
                .frame(maxWidth: .infinity)
                .font(.custom("MontserratAlternates-ExtraBold", size: 35))
                .foregroundColor(davysGray)
            
            Text(teams[wager.bettor_chosen_team] ?? "Reload")
                .padding(.bottom)
                .frame(maxWidth: .infinity)
                .font(.custom("MontserratAlternates-ExtraBold", size: 45))
                .foregroundColor(Color("Accent2"))
                .multilineTextAlignment(.trailing)
            
            Text("Wager Amount")
                .padding(.top)
                .frame(maxWidth: .infinity)
                .font(.custom("MontserratAlternates-ExtraBold", size: 40))
                .foregroundColor(davysGray)
            
            Text("\(NSDecimalNumber(decimal: wager.wager_amount).stringValue) LTC")
                .frame(maxWidth: .infinity)
                .font(.custom("MontserratAlternates-ExtraBold", size: 40))
                .foregroundColor(Color("Accent2"))

            Text("$\(NSDecimalNumber(decimal: wager.wager_amount).floatValue * viewModel.usdPrice, specifier: "%.2f")")
                .padding(.bottom)
                .frame(maxWidth: .infinity)
                .font(.custom("MontserratAlternates-ExtraBold", size: 40))
                .foregroundColor(Color("Accent2"))
            
            Text("Game Time")
                .padding(.top)
                .frame(maxWidth: .infinity)
                .font(.custom("MontserratAlternates-ExtraBold", size: 40))
                .foregroundColor(davysGray)
            
            Text("\(viewModel.formatDate(date: viewModel.gameStarts))")
                .padding(.bottom)
                .frame(maxWidth: .infinity)
                .font(.custom("MontserratAlternates-ExtraBold", size: 35))
                .foregroundColor(Color("Accent2"))
            
            Spacer()
            
            Button("Place bet") {
                guard
                    viewModel.buttonPressed == false,
                    viewModel.dataSubmitted == false
                else { return }

                // Add logic to save the bet if the fader confirms
                viewModel.updateWager(token: user.accessToken, wagerId: wager.id, fader: user.walletAddress, user: user)
            }
            .padding()
            .foregroundColor(davysGray)
            .background(
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).fill(LinearGradient(gradient: Gradient(colors: [Color("Accent2"), Color("Accent")]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
            )
            .alert(isPresented: $viewModel.showingAlert) {
                if viewModel.dataSubmitted {
                    return  Alert(
                        title: Text("Important message"),
                        message: Text("The wager is now active. The wager amount will be sent to escrow from your wallet. Once the game is over, the person who chose the correct team will have their wallet funded with the winnings."),
                        dismissButton: .default(Text("Got it!"))
                    )
                } else {
                    if !viewModel.hasEnoughCrypto {
                        return  Alert(
                            title: Text("Important message"),
                            message: Text("You don't have enough crypto to take this bet. Add more to your wallet."),
                            dismissButton: .default(Text("Got it!"))
                        )
                    } else {
                        return  Alert(
                            title: Text("Important message"),
                            message: Text("You can't take your own bet. Go back and choose another one."),
                            dismissButton: .default(Text("Got it!"))
                        )
                    }
                }
                
            }
            
        }
        .padding()
        .disabled(viewModel.buttonPressed)
        .onAppear() {
            viewModel.getGameTime(gameId: UInt(wager.game_id), user: user)
            if (user.walletAddress == wager.bettor) {
                viewModel.buttonPressed.toggle()
                viewModel.showingAlert.toggle()
            }
            if viewModel.usdPrice == 0.0 {
                viewModel.getCurrentLtcPrice()
            }
            viewModel.checkWalletBalance(address: user.walletAddress, username: user.username, token: user.accessToken, amount: wager.wager_amount, user: user)
        }
    }
}

struct WagerDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        WagerDetailsView(wager: WagerModel(id: 5, bettor: "Asim", wager_amount: 33, game_id: 23, is_active: true, bettor_chosen_team: 12))
    }
}
