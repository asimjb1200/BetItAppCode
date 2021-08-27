//
//  AccountDetails.swift
//  BetIt
//
//  Created by Asim Brown on 6/29/21.
//

import SwiftUI
import Combine

var window = UIApplication.shared.windows.first
var signalAlert = PassthroughSubject<Void,Never>()

struct AccountDetails: View {
    @EnvironmentObject private var user: UserModel
//    @State private var showingCustomSheet = false
    var accountOptions = ["Email", "Password", "View My Wagers", "Support", "Deactivate", "Log Out"]
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    var body: some View {
        NavigationView {
            List {
                ForEach(accountOptions, id: \.self) { item in
                    switch item {
                    case AccountDeets.email.rawValue:
                        NavigationLink("\(item)", destination: ChangeEmail())
                    case AccountDeets.password.rawValue:
                        NavigationLink("\(item)", destination: ChangePassword())
                    case AccountDeets.support.rawValue:
                        NavigationLink("\(item)", destination: Text("Contact Support"))
                    case AccountDeets.deactivate.rawValue:
                        NavigationLink("\(item)", destination: Text("Deactivate Account"))
                    case AccountDeets.viewMyWagers.rawValue:
                        NavigationLink("\(item)", destination: StatusOfUsersWagers())
                    default:
                        Button(action: {
                            UserNetworking().logout(accessToken: user.accessToken, completion: { loggedOutStatus in
                                switch loggedOutStatus {
                                case .success( _):
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
            }.navigationTitle("Account Details")
        }
    }
}


struct AccountDetails_Previews: PreviewProvider {
    static var previews: some View {
        AccountDetails()
    }
}
