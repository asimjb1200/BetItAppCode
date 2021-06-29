//
//  AccountDetails.swift
//  BetIt
//
//  Created by Asim Brown on 6/29/21.
//

import SwiftUI

struct AccountDetails: View {
    @EnvironmentObject var user: UserModel
    var body: some View {
        Button(action: {
            UserNetworking().logout(accessToken: user.accessToken, completion: { loggedOutStatus in
                switch loggedOutStatus {
                case .success(let isLoggedOut):
                    DispatchQueue.main.async {
                        user.logUserOut()
                    }
                case .failure(let err):
                    print(err)
                }
                
            })
        }, label: {
            Text("Log Out")
        })
    }
}

struct AccountDetails_Previews: PreviewProvider {
    static var previews: some View {
        AccountDetails()
    }
}
