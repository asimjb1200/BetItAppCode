//
//  StatusOfUsersWagersViewModel.swift
//  BetIt
//
//  Created by Asim Brown on 8/20/21.
//

import Foundation

final class StatusOfUsersWagersVM: ObservableObject {
    @Published var myWagers: [WagerStatus] = []
    private var wagerService: WagerService = .shared
    private var dateFormatter = DateFormatter()
    
    init() {
        self.dateFormatter.dateFormat = "MMM d, h:mm a"
    }
    
    func getUsersWagers(token: String, bettor: String, user: UserModel) {
        wagerService.getAllUsersWagers(token: token, bettor: bettor, completion: {[weak self] usersWagersResponse in
            switch usersWagersResponse {
                case .success(let usersWagers):
                    DispatchQueue.main.async {
                        self?.myWagers = usersWagers
                    }
                case .failure(let err):
                    if err == .tokenExpired {
                        DispatchQueue.main.async {
                            user.logUserOut()
                        }
                    }
                    print(err)
            }
        })
    }
    
    func convertDateToString(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
