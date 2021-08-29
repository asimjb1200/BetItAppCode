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
            
            ForEach(viewModel.myWagers, id: \.self) { wager in
                MySingleWager(ltcAmount: wager.amount, chosenTeam: wager.chosenTeam, gameDate: dateToString(date: wager.gameStartTime))
            }
        }.onAppear() {
            if viewModel.myWagers.isEmpty {
                viewModel.getUsersWagers(token: user.accessToken, bettor: user.walletAddress)
            }
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
