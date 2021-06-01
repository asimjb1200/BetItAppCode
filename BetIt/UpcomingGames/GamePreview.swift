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
    
    init(homeTeam: UInt8, awayTeam: UInt8) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
    }

    var body: some View {
        HStack {
            Text("\(homeTeam)")
                .font(.custom("Roboto-Light", size: 30))
                .foregroundColor(Color(hue: 0.452, saturation: 0.804, brightness: 0.99))
            
            Text("vs.")
                .foregroundColor(Color(hue: 0.452, saturation: 0.804, brightness: 0.99))
            
            Text("\(awayTeam)")
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
