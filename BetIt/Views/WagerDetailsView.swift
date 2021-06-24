//
//  WagerDetailsView.swift
//  BetIt
//
//  Created by Asim Brown on 6/9/21.
//

import SwiftUI

struct WagerDetailsView: View {
    @ObservedObject var wager: WagerModel
    @ObservedObject var wagersOnGame: GameWagers = .shared
//    @EnvironmentObject var user: User
    @EnvironmentObject var userManager: UserManager
    @State private var buttonPressed: Bool = false
    @State private var showingAlert = false
    @State private var dataSubmitted = false
    let teams = TeamsMapper().Teams
    let accentColor = Color("Accent2")
    let davysGray = Color(white: 0.342)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("You will be betting against: " +  (teams[wager.bettor_chosen_team] ?? "Reload")).foregroundColor(accentColor)
            Text("Wager Amount: \(wager.wager_amount) LTC").foregroundColor(accentColor)
            Text("Amount in USD: $250").foregroundColor(accentColor)
            Button(action: {
                // quick check to see if bet is still open
                
                // Add logic to save the bet if the fader confirms
                self.updateWager()
                
                // disable the button to prevent double submittal
                buttonPressed.toggle()
                
                // inform the user that the bet has been successfully submitted
                dataSubmitted.toggle()
                showingAlert.toggle()
                
            }, label: {
                Text("Take this bet")
                    .padding()
                    .foregroundColor(accentColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                            .stroke(accentColor, lineWidth: 2)
                    )
            })
            .alert(isPresented: $showingAlert) {
                if self.dataSubmitted {
                    return  Alert(
                                    title: Text("Important message"),
                                    message: Text("The wager is now active. The wager amount will be sent to escrow from your wallet. Once the game is over, the person who chose the correct team will have their wallet funded with the winnings."),
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
        }.padding()
        .overlay(
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                .stroke(Color("Accent2"), lineWidth: 4)
        )
        .font(.custom("Roboto-Light", size: 20))
        .disabled(buttonPressed)
        .onAppear() {
            if (bettorAndFaderAddressMatch()) {
                self.buttonPressed.toggle()
                self.showingAlert.toggle()
            }
        }
    }
}

extension WagerDetailsView {
    func updateWager() {
        WagerService().updateWager(token: userManager.user.access_token, wagerId: wager.id, fader: userManager.user.wallet_address, completion: { (updatedWager) in
            switch updatedWager {
            case .success(let newWager):
                DispatchQueue.main.async {
                    //                        wager.fader = newWager.fader
                    //                        wager.is_active = true
                    // remove the wager from the list of wagers
                    self.wagersOnGame.wagers = self.wagersOnGame.wagers.filter{$0.id != newWager.id}
                }
            case .failure(let err):
                print(err)
            }
        })
    }
    
    func bettorAndFaderAddressMatch() -> Bool {
        return userManager.user.wallet_address == wager.bettor ? true : false
    }
}

struct WagerDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        WagerDetailsView(wager: WagerModel(id: 5, bettor: "Asim", wager_amount: 33, game_id: 23, is_active: true, bettor_chosen_team: 12))
    }
}
