//
//  LoadingView.swift
//  BetIt
//
//  Created by Asim Brown on 7/23/21.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView("loading...")
            .progressViewStyle(CircularProgressViewStyle(tint: Color("Accent2")))
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
