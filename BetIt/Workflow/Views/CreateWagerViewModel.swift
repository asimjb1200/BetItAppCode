//
//  CreateWagerViewModel.swift
//  BetIt
//
//  Created by Asim Brown on 8/10/21.
//

import Foundation

final class CreateWagerViewModel: ObservableObject {
    
    @Published var selectedDate = Date()
    @Published var wagerAmount = "0.0"
    @Published var games = [DBGame]()
    @Published var selectedGame = DBGame(game_id: 0, sport: "", home_team: 0, visitor_team: 0, game_begins: Date(), season: 0) {
        didSet {
            selectedTeam = 0
        }
    }
    @Published var selectedTeam: UInt8 = 0
    @Published var showAlert = false
    var wagerCreated = false
    private var gameService: GameService = .shared
    private var wagerService: WagerService = .shared
    private var dateFormatter = DateFormatter()
    var dateToString: String {
        return formatDate()
    }
    
    
    let pastDays = Date().addingTimeInterval(-604800)
    
    // add 7 days to the current date
    let range = Date() ... Date().addingTimeInterval(604800)
    
    init() {
        self.dateFormatter.dateFormat = "EEE, MMM d, yyyy"
    }
    
    func loadGames(date: Date, token: String) {
        gameService.getGamesByDate(token: token, date: date, completion: {gameResults in
            switch gameResults {
            case .success(let gamesOnDate):
                    DispatchQueue.main.async {
                        self.games = gamesOnDate
                        if !gamesOnDate.isEmpty {
                            self.selectedGame = gamesOnDate[0]
                        }
                        // reset the selected team everytime a game is loaded
                        self.selectedTeam = 0
                    }
            case .failure(let err):
                print(err)
            }
        })
    }
    
    func placeBet(token: String, bettor: String) {
        wagerService.createNewWager(token: token, bettor: bettor, wagerAmount: UInt(self.wagerAmount) ?? 0, gameId: self.selectedGame.game_id, bettorChosenTeam: UInt(self.selectedTeam), completion: { wagerResult in
            switch wagerResult {
            case .success(let newWagerCreated):
                DispatchQueue.main.async {
                    self.wagerCreated = newWagerCreated
                    self.showAlert = true
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    self.wagerCreated = false
                    self.showAlert = true
                    print(err)
                }
            }
        })
    }
    
    func formatDate() -> String {
//        let dateString = dateFormatter.string(from: self.selectedDate)
        return dateFormatter.string(from: self.selectedDate)
    }
}
