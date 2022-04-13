//
//  StatusOfUsersWagers.swift
//  BetIt
//
//  Created by Asim Brown on 8/20/21.
//

import SwiftUI

struct StatusOfUsersWagers: View {
    @EnvironmentObject private var user: UserModel
    @StateObject private var viewModel: StatusOfUsersWagersVM = StatusOfUsersWagersVM()
    var body: some View {
        VStack {
            Text("Your Current Wagers").font(.custom("MontserratAlternates-Regular", size: 25)).padding(.bottom)
            
            if !viewModel.myWagers.isEmpty {
                Text("Note: You can only cancel a bet if no one has taken it yet.")
                    .font(.custom("MontserratAlternates-Light", size: 15))
                ScrollView {
                    VStack{
                        ForEach(viewModel.myWagers, id: \.self) { wager in
                            MySingleWager(ltcAmount: wager.amount, chosenTeam: wager.chosenTeam, gameDate: dateToString(date: wager.gameStartTime), wagerId: wager.wagerId, isActive: wager.isActive)
                        }
                    }
                }
            } else {
                Text("You don't have any active wagers right now").font(.custom("MontserratAlternates-Regular", size: 19))
            }
        }.onAppear() {
            viewModel.getUsersWagers(token: user.accessToken, bettor: user.walletAddress, user: user)
        }
    }
}

extension StatusOfUsersWagers {
    func dateToString(date: Date) -> String {
        return viewModel.convertDateToString(date: date)
    }
}

struct StatusOfUsersWagers_Previews: PreviewProvider {
    static var previews: some View {
        StatusOfUsersWagers()
    }
}
