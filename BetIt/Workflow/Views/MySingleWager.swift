//
//  MySingleWager.swift
//  BetIt
//
//  Created by Asim Brown on 8/25/21.
//

import SwiftUI

struct MySingleWager: View {
    @State var ltcAmount: Int = 0
    @State var chosenTeam: Int = 0
    @State var showAlert: Bool = false
    private let teams = TeamsMapper().Teams
    let davysGray = Color(white: 0.342)
    var body: some View {
        VStack {
            Text("Game Starts: Sun, Aug 3rd 4pm")
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
                return Alert(title: Text("Are You Sure?"), primaryButton: .destructive(Text("Cancel the wager"), action: cancelMyWager), secondaryButton: .default(Text("Nevermind")))
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

    }
}

extension MySingleWager {
    func cancelMyWager() -> () {
        print("wager cancelled")
    }
}

struct MySingleWager_Previews: PreviewProvider {
    static var previews: some View {
        MySingleWager(ltcAmount: 3, chosenTeam: 4)
    }
}
