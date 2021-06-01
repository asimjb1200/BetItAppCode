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
        HStack {
            Text(self.Teams[homeTeam] ?? "Retry Request")
                .font(.custom("Roboto-Light", size: 30))
                .foregroundColor(Color(hue: 0.452, saturation: 0.804, brightness: 0.99))
            
            Text("vs.")
                .foregroundColor(Color(hue: 0.452, saturation: 0.804, brightness: 0.99))
            
            Text(self.Teams[awayTeam] ?? "Retry Request")
                .font(.custom("Roboto-Light", size: 30))
                .foregroundColor(Color(hue: 0.452, saturation: 0.804, brightness: 0.99))
            
            Spacer()
            Text("7:30pm ET")
                .padding(.trailing)
                .foregroundColor(Color(hue: 0.452, saturation: 0.804, brightness: 0.99))
            .font(.custom("Roboto-Light", size: 20))
        }
        .padding([.top, .leading, .bottom])
        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.gray/*@END_MENU_TOKEN@*/)
        
    }
}

struct GamePreview_Previews: PreviewProvider {
    static var previews: some View {
        GamePreview(homeTeam: 1, awayTeam: 2)
    }
}
