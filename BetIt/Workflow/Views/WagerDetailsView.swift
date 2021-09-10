//
//  WagerDetailsView.swift
//  BetIt
//
//  Created by Asim Brown on 6/9/21.
//

import SwiftUI

struct WagerDetailsView: View {
    @ObservedObject var wager: WagerModel
    @StateObject var viewModel: GameWagersViewModel = .shared
    @EnvironmentObject var user: UserModel
    @State private var dataSubmitted = false
    var usdPrice: Float = 0.0
    var service: WalletService = .shared
    let teams = TeamsMapper().Teams
    let accentColor = Color("Accent2")
    let davysGray = Color(white: 0.342)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("You will be betting against: " +  (teams[wager.bettor_chosen_team] ?? "Reload"))
                .foregroundColor(.white)
            Text("Wager Amount: \(wager.wager_amount) LTC")
                .foregroundColor(.white)
            Text("Amount in USD: $\(Float(wager.wager_amount) * viewModel.usdPrice, specifier: "%.2f")")
                .foregroundColor(.white)
            Button("Take this bet") {
                    // Add logic to save the bet if the fader confirms
                    viewModel.updateWager(token: user.accessToken, wagerId: wager.id, fader: user.walletAddress)
                    
                    // disable the button to prevent double submittal
                    viewModel.buttonPressed.toggle()
                    
                    // inform the user that the bet has been successfully submitted
                    dataSubmitted.toggle()
                    viewModel.showingAlert.toggle()
            }
            .padding()
            .foregroundColor(.white)
            .alert(isPresented: $viewModel.showingAlert) {
                if self.dataSubmitted {
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
            
        }.padding()
        .background(
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                .fill(Color("Accent2"))
        )
        .font(.custom("Roboto-Light", size: 20))
        .disabled(viewModel.buttonPressed)
        .onAppear() {
            if (viewModel.bettorAndFaderAddressMatch(fader: user.walletAddress, bettor: wager.bettor)) {
                viewModel.buttonPressed.toggle()
                viewModel.showingAlert.toggle()
            }
            if viewModel.usdPrice == 0.0 {
                viewModel.getCurrentLtcPrice()
            }
            viewModel.checkWalletBalance(address: user.walletAddress, username: user.username, token: user.accessToken, amount: wager.wager_amount)
        }
    }
}

struct WagerDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        WagerDetailsView(wager: WagerModel(id: 5, bettor: "Asim", wager_amount: 33, game_id: 23, is_active: true, bettor_chosen_team: 12))
    }
}
