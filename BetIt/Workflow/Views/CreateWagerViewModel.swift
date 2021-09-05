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
    @Published var selectedTeam: UInt8 = 0
    @Published var showAlert = false
    @Published var canWager: Bool = true
    @Published var notEnoughCrypto: Bool = false
    @Published var selectedGame = DBGame(game_id: 0, sport: "", home_team: 0, visitor_team: 0, game_begins: Date(), season: 0) {
        didSet {
            selectedTeam = 0
        }
    }
    var wagerCreated = false
    private var gameService: GameService = .shared
    private var wagerService: WagerService = .shared
    private var dateFormatter = DateFormatter()
    private var walletService: WalletService = .shared
    private var ltcFeeWiggleRoom = 0.05/100000000
    var dateToString: String {
        return formatDate()
    }
    
    
    let pastDays = Date().addingTimeInterval(-604800)
    
    // add 7 days to the current date
    let range = Date() ... Date().addingTimeInterval(604800)
    
    init() {
        self.dateFormatter.dateFormat = "MMM d, h:mm a"
    }
    
    func checkWagerCount(bettor: String, token: String) {
        wagerService.checkUserWagerCount(token: token, bettor: bettor, completion: {apiResponse in
            switch apiResponse {
            case .success(let numOfWagers):
                DispatchQueue.main.async {
                    if numOfWagers >= 2 {
                        self.canWager = false
                    } else {
                        self.canWager = true
                    }
                }
            case .failure(let err):
                print(err)
            }
        })
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
        return dateFormatter.string(from: self.selectedGame.game_begins)
    }
    
    func checkWalletBalance(address: String, username: String, token: String){
        walletService.getWalletBalance(address: address, username: username, token: token, completion: {walletResponse in
            switch walletResponse {
                case .success(let walletData):
                    DispatchQueue.main.async {
                        let litoshiBalance = Decimal(string: self.wagerAmount)!/100000000 // think of a clever way to tack on the tx fees
                        if walletData.balance <= (litoshiBalance + Decimal(self.ltcFeeWiggleRoom)) {
                            self.notEnoughCrypto = true
                            self.showAlert = true
                        } else {
                            self.placeBet(token: token, bettor: address)
                        }
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        self.notEnoughCrypto = true
                        self.showAlert = true
                        print(err)
                    }
            }
        })
    }
}
