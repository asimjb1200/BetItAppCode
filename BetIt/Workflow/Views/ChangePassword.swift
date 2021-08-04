//
//  ChangePassword.swift
//  BetIt
//
//  Created by Asim Brown on 7/31/21.
//

import SwiftUI

struct ChangePassword: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var newPasswordAgain = ""
    @State private var showAlert = false
    @State private var passwordChanged = false
    @EnvironmentObject var user: UserModel
    var body: some View {
        VStack {
            TextField("Current Password: ", text: $currentPassword)
                .padding(.vertical)
            SecureField("New Password: ", text: $newPassword)
                .padding(.vertical)
            SecureField("New Password Again: ", text: $newPasswordAgain)
                .padding(.vertical)
            
            Button("Save Password") {
                guard
                    newPassword == newPasswordAgain, !currentPassword.isEmpty,
                    !newPassword.isEmpty, !newPassword.trimmingCharacters(in: .whitespaces).isEmpty // this makes sure they don't send in a space string
                else {
                    showAlert.toggle()
                    return
                }
                updatePassword(newPassword: newPassword, oldPassword: currentPassword)
            }
            .padding(.all)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color.black)
            )
            
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .leading, endPoint: .trailing)
                )
        )
        .alert(isPresented: $showAlert) {
            switch passwordChanged {
            case false:
                return Alert(
                            title: Text("New Passwords Don't Match"),
                            message: Text("Double check both of your new password fields." +
                                    " Make sure they match and aren't empty.")
                            )
            case true:
                return Alert(
                            title: Text("Success"),
                            message: Text("Your password")
                            )
            }
        }
    }
}

extension ChangePassword {
    func updatePassword(newPassword: String, oldPassword: String) {
        UserNetworking().changePassword(newPassword: newPassword, username: user.username, oldPassword: oldPassword, token: user.accessToken, completion: { message in
            switch message{
            case .success( _):
                DispatchQueue.main.async {
                    self.passwordChanged = true
                    self.showAlert = true
                }
            case .failure(let err):
                print(err)
            }
        })
    }
}

struct ChangePassword_Previews: PreviewProvider {
    static var previews: some View {
        ChangePassword()
    }
}

enum PasswordStates: Int {
    case updated = 0
    case incorrectPassword = 1
    case passwordNotFound = 2
}
