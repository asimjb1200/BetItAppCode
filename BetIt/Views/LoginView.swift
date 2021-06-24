//
//  LoginView.swift
//  BetIt
//
//  Created by Asim Brown on 6/14/21.
//

import SwiftUI

struct LoginView: View {
//    @EnvironmentObject var user: User
    @EnvironmentObject var userManager: UserManager
    @State private var username: String = ""
    @State private var password: String = ""
    var body: some View {
        ZStack {
            Image("AppLogo")
            .resizable()
            .scaledToFit()
            VStack {
                TextField("Username", text: $username)
                    .padding([.top, .leading, .bottom])
                    .background(Capsule().fill(Color(white: 0.3, opacity: 0.734)))
                    .frame(width: 300.0)
                SecureField("Password", text: $password)
                    .padding([.top, .leading, .bottom])
                    .background(Capsule().fill(Color(white: 0.3, opacity: 0.734)))
                    .frame(width: 300.0)
                Button(action: {
                    userManager.user.login(username: username, pw: password, completion: { (authedUser) in
                        switch authedUser {
                            case .success(let foundUser):
                                DispatchQueue.main.async {
//                                    userManager.user.username = foundUser.username
//                                    userManager.user.access_token = foundUser.access_token
//                                    userManager.user.refresh_token = foundUser.refresh_token
//                                    userManager.user.wallet_address = foundUser.wallet_address
//                                    userManager.user.isLoggedIn = true
                                    self.userManager.updateUser(username: foundUser.username, access_token: foundUser.access_token, refresh_token: foundUser.refresh_token, wallet_address: foundUser.wallet_address)
                                }
                            case .failure(let err):
                                print(err)
                        }
                    });
                }, label: {
                    Text("Log In")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).fill(Color("Accent2"))
                        )
                        .foregroundColor(.black)
                })
            }.offset(y: 175)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(User())
    }
}
