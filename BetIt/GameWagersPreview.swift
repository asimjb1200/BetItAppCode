//
//  GameWagersView.swift
//  BetIt
//
//  Created by Asim Brown on 6/8/21.
//

import SwiftUI

class WagerModel: ObservableObject, Identifiable, Codable{
    
    enum CodingKeys: CodingKey {
        case fader
        case wager_amount
        case is_active
        case winning_team
        case id
        case bettor
        case game_id
        case bettor_chosen_team
        case escrow_address
    }
    
    var id: Int
    @Published var bettor: String
    @Published var fader: String?
    @Published var wager_amount: Int
    @Published var game_id: Int
    @Published var is_active: Bool
    @Published var bettor_chosen_team: Int
    @Published var winning_team: Int?
    @Published var escrow_address: String?
    
    // tell swift how to decode data into the published types
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        bettor = try container.decode(String.self, forKey: .bettor)
        game_id = try container.decode(Int.self, forKey: .game_id)
        bettor_chosen_team = try container.decode(Int.self, forKey: .bettor_chosen_team)
        fader = try container.decodeIfPresent(String.self, forKey: .fader)
        wager_amount = try container.decode(Int.self, forKey: .wager_amount)
        is_active = try container.decode(Bool.self, forKey: .is_active)
        winning_team = try container.decodeIfPresent(Int.self, forKey: .winning_team)
        escrow_address = try container.decodeIfPresent(String.self, forKey: .escrow_address)
    }
    
    init(id: Int, bettor: String, wager_amount: Int, game_id: Int, is_active: Bool, bettor_chosen_team: Int) {
        self.id = id
        self.bettor = bettor
        self.wager_amount = wager_amount
        self.game_id = game_id
        self.is_active = is_active
        self.bettor_chosen_team = bettor_chosen_team
    }
    
    // now tell swift how to encode my type
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(bettor, forKey: .bettor)
        try container.encodeIfPresent(fader, forKey: .fader)
        try container.encode(wager_amount, forKey: .wager_amount)
        try container.encode(game_id, forKey: .game_id)
        try container.encode(is_active, forKey: .is_active)
        try container.encodeIfPresent(winning_team, forKey: .winning_team)
        try container.encodeIfPresent(bettor_chosen_team, forKey: .bettor_chosen_team)
        try container.encodeIfPresent(escrow_address, forKey: .escrow_address)
    }
}

struct GameWagersPreview: View {
    @ObservedObject var wager: WagerModel
    var body: some View {
        VStack {
            Text("\(wager.wager_amount) Ltc \n Bettor's Pick: \(wager.bettor_chosen_team)")
                .multilineTextAlignment(.center)
                .padding(.all)
                .fixedSize(horizontal: false, vertical: true)
                .font(.custom("Roboto-Medium", size: 25))
                .foregroundColor(Color.gray)
                .background(
                    Capsule()
                        .fill(Color("Accent"))
                )
            
            Button(action: {
                self.wager.wager_amount = 10
                        }) {
                            Text("change bet amount")
                        }
        }
    }
}

struct GameWagersPreview_Previews: PreviewProvider {
    static var previews: some View {
        Text("k")
//        GameWagersPreview(wager: WagerModel(id: 5, bettor: "Asim", wager_amount: 5, game_id: 6, is_active: true, bettor_chosen_team: 8, escrow_address: "test"))
    }
}
