//
//  GamePreview.swift
//  BetIt
//
//  Created by Asim Brown on 5/29/21.
//

import SwiftUI

struct GamePreview: View {
    var homeTeam: UInt8
    var awayTeam: UInt8
    let Teams: [UInt8: String] = [
        1: "ATL",
        2: "BOS",
        3: "BKN",
        4: "CHA",
        5: "CHI",
        6: "CLE",
        7: "DAL",
        8: "DEN",
        9: "DET",
        10: "GSW",
        11: "HOU",
        12: "IND",
        13: "LAC",
        14: "LAL",
        15: "MEM",
        16: "MIA",
        17: "MIL",
        18: "MIN",
        19: "NOP",
        20: "NYK",
        21: "OKC",
        22: "ORL",
        23: "PHI",
        24: "PHX",
        25: "POR",
        26: "SAC",
        27: "SAS",
        28: "TOR",
        29: "UTA",
        30: "WAS"
    ]
    
    init(homeTeam: UInt8, awayTeam: UInt8) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
    }
    

    var body: some View {
        VStack(alignment: .center, spacing: 0.0) {
            Text(self.Teams[homeTeam] ?? "Retry Request")
                .font(.custom("Roboto-Light", size: 30))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Text("vs.")
                .foregroundColor(.gray)
            
            Text(self.Teams[awayTeam] ?? "Retry Request")
                .font(.custom("Roboto-Light", size: 30))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Text("7:30pm ET")
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.gray)
            .font(.custom("Roboto-Light", size: 20))
        }
        .background(RoundedRectangle(cornerRadius: 25)
                        .stroke(Color(hue: 0.452, saturation: 0.804, brightness: 0.60), lineWidth: 2))
        
    }
}

struct GamePreview_Previews: PreviewProvider {
    static var previews: some View {
        GamePreview(homeTeam: 1, awayTeam: 2)
    }
}
