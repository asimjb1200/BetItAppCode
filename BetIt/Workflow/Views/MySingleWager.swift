//
//  MySingleWager.swift
//  BetIt
//
//  Created by Asim Brown on 8/25/21.
//

import SwiftUI

struct MySingleWager: View {
    var ltcAmount: Int
    var chosenTeam: Int
    var gameDate: String
    var wagerId: Int
    @EnvironmentObject private var user: UserModel
    @State var showAlert: Bool = false
    private let teams = TeamsMapper().Teams
    @State private var wagerIsCanceled = false
    let davysGray = Color(white: 0.342)
    var body: some View {
        if !wagerIsCanceled {
            VStack {
                Text("Game Starts: \(gameDate)")
                Text("Wager Amount: \(ltcAmount) LTC")
                Text("Your Chosen Team: \(teams[UInt8(chosenTeam)]!)")
                Text("Bet Is Active: No")
                Button("Cancel Wager") {
                    showAlert.toggle()
                }
                .foregroundColor(davysGray)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(Color("Accent2"))
                )
                .alert(isPresented: $showAlert) {
                    return Alert(title: Text("Are You Sure?"), primaryButton: .destructive(Text("Cancel the Wager"), action: cancelMyWager), secondaryButton: .default(Text("Nevermind")))
                }
            }
            .padding()
            .font(.custom("MontserratAlternates-Regular", size: 18))
            .frame(
              minWidth: 0,
              maxWidth: .infinity,
              alignment: .center
            )
            .background(
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                    .fill(davysGray)
            )
        } else {
            Text("The wager was cancelled")
        }

    }
}

extension MySingleWager {
    func cancelMyWager() -> () {
        WagerService.shared.cancelWager(token: user.accessToken, wagerId: self.wagerId, completion: {result in
            switch result {
            case .success( _):
                DispatchQueue.main.async {
                    self.wagerIsCanceled.toggle()
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    print("A problem occured: \(err)")
                }
            }
        })
    }
}

struct MySingleWager_Previews: PreviewProvider {
    static var previews: some View {
        MySingleWager(ltcAmount: 3, chosenTeam: 4, gameDate: "sept 4th 97", wagerId: 5)
    }
}
