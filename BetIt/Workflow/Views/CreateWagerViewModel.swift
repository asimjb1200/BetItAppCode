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
//    @Published var games: [DBGame] = [DBGame(game_id: 0, sport: "", home_team: 0, visitor_team: 0, game_begins: Date(), season: 0), DBGame(game_id: 1, sport: "", home_team: 0, visitor_team: 0, game_begins: Date(), season: 0)]
    @Published var selectedTeam: UInt8 = 0
    @Published var showAlert = false
    @Published var canWager: Bool = true
    @Published var notEnoughCrypto: Bool = false
    @Published var currLtcPrice: String = "1.0"
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
    
    func checkWagerCount(bettor: String, token: String, user: UserModel) {
        wagerService.checkUserWagerCount(token: token, bettor: bettor, completion: {[weak self] apiResponse in
            switch apiResponse {
            case .success(let numOfWagersResponse):
                DispatchQueue.main.async {
                    if numOfWagersResponse.dataForClient.numberOfBets >= 2 {
                        self?.canWager = false
                    } else {
                        self?.canWager = true
                    }
                    
                    if let newAccessToken = numOfWagersResponse.newAccessToken {
                        user.accessToken = newAccessToken
                    }
                }
            case .failure(let err):
                if err == .tokenExpired {
                    user.logUserOut()
                }
                print(err)
            }
        })
    }
    
    func loadGames(date: Date, token: String, user: UserModel) {
        gameService.getGamesByDate(token: token, date: date, completion: {[weak self] gameResults in
            switch gameResults {
            case .success(let gamesOnDate):
                    DispatchQueue.main.async {
                        self?.games = gamesOnDate.dataForClient
                        if !gamesOnDate.dataForClient.isEmpty {
                            self?.selectedGame = gamesOnDate.dataForClient[0]
                        }
                        // reset the selected team everytime a game is loaded
                        self?.selectedTeam = 0
                        
                        guard let
                                newAccessToken = gamesOnDate.newAccessToken
                        else {
                            return // if newAccessToken is nil, the function will return and skip the code below
                        }
                        user.accessToken = newAccessToken
                    }
            case .failure(let err):
                if err == .tokenExpired {
                    user.logUserOut()
                }
                print(err)
            }
        })
    }
    
    func getCurrLtcPrice() {
        walletService.getCurrentLtcPrice(completion: {[weak self] ltcPriceDataRes in
            switch ltcPriceDataRes {
            case .success(let ltcPriceData):
                DispatchQueue.main.async {
                    self?.currLtcPrice = ltcPriceData.data.amount
                }
            case .failure(let err):
                print(err)
            }
        })
    }
    
    func placeBet(token: String, bettor: String, user: UserModel) {
        wagerService.createNewWager(token: token, bettor: bettor, wagerAmount: Decimal(string: self.wagerAmount)!, gameId: self.selectedGame.game_id, bettorChosenTeam: UInt(self.selectedTeam), completion: {[weak self]  wagerResult in
                switch wagerResult {
                    case .success(let newWagerCreated):
                        DispatchQueue.main.async {
                            self?.wagerCreated = newWagerCreated
                            self?.notEnoughCrypto = false
                            self?.showAlert = true
                        }
                    case .failure(let err):
                        if err == .tokenExpired {
                            user.logUserOut()
                        } else {
                            DispatchQueue.main.async {
                                self?.wagerCreated = false
                                self?.showAlert = true
                                print(err)
                            }
                        }
                }
        })
    }
    
    func formatDate() -> String {
        return dateFormatter.string(from: self.selectedGame.game_begins)
    }
    
    func calcLtcAmount(wagerAmountInDollars: String) -> Decimal {
        guard
            let usdDecimal = Decimal(string: wagerAmountInDollars)
        else {
            return 0
        }
        var rounded = Decimal()
        // find out how much ltc is needed to cover the bet
        var ltcAmountToWager: Decimal = usdDecimal/(Decimal(string: self.currLtcPrice) ?? 1.0)
        NSDecimalRound(&rounded, &ltcAmountToWager, 7, .bankers)
        return rounded
    }
    
    func checkWalletBalance(address: String, username: String, token: String, user: UserModel){
        walletService.getWalletBalance(address: address, username: username, token: token, completion: {[weak self]  walletResponse in
            switch walletResponse {
                case .success(let walletData):
                    DispatchQueue.main.async {
                        guard let cryptoAmount = self?.calcLtcAmount(wagerAmountInDollars: self?.wagerAmount ?? "0") else {
                            return
                        }
                        if walletData.dataForClient.balance <= cryptoAmount {
                            self?.notEnoughCrypto = true
                            self?.showAlert = true
                        } else {
                            self?.placeBet(token: token, bettor: address, user: user)
                        }
                        
                        guard let newAccessToken = walletData.newAccessToken else { return }
                        user.accessToken = newAccessToken
                    }
                case .failure(let err):
                    if err == .tokenExpired {
                        user.logUserOut()
                    } else {
                        DispatchQueue.main.async {
                            self?.notEnoughCrypto = true
                            self?.showAlert = true
                            print(err)
                        }
                    }
            }
        })
    }
}
