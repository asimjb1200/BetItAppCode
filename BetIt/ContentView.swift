//
//  ContentView.swift
//  BetIt
//
//  Created by Asim Brown on 5/29/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("The content of the first view")
                .tabItem {
                    Image(systemName: "house.fill")
                }
            
            UpcomingGames()
//                Text("Screen 2")
                .tabItem {
                    Image(systemName: "person.fill")
                }
            
            Text("The content of the third view")
                .tabItem {
                    Image(systemName: "plus")
                }
            
            Text("The content of the fourth view")
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    
                }
            
            Text("The content of the fifth view")
                .tabItem {
                    Image(systemName: "percent")
                }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
