//
//  GamesNotFound.swift
//  BetIt
//
//  Created by Asim Brown on 6/25/21.
//

import SwiftUI

struct GamesNotFound: View {
    var date: String
    var body: some View {
        VStack {
            Image("question")
            Text("No games scheduled on: \(date)")
                .bold()
                .font(.custom("MontserratAlternates-Regular", size: 20))
                .foregroundColor(.gray)
            Text("Try another date")
                .bold()
                .font(.custom("MontserratAlternates-Regular", size: 20))
                .foregroundColor(.gray)
        }.frame(maxHeight: .infinity).edgesIgnoringSafeArea(.all)
    }
}

struct GamesNotFound_Previews: PreviewProvider {
    static var previews: some View {
        GamesNotFound(date: "06/01/21")
    }
}
