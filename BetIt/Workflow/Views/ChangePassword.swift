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
    @State private var passwordState: PasswordStates = .noActionYet
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
                    newPassword == newPasswordAgain
                else {
                    self.passwordState = .passwordsDontMatch
                    showAlert.toggle()
                    return
                }
                
                guard
                    !currentPassword.isEmpty,
                    !newPassword.isEmpty, !newPassword.trimmingCharacters(in: .whitespaces).isEmpty
                else {
                    self.passwordState = .passwordsEmpty
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
            switch passwordState {
                case .passwordsDontMatch:
                    return Alert(
                                title: Text("New Passwords Don't Match"),
                                message: Text("Double check both of your new password fields." +
                                        " Make sure they match and aren't empty.")
                                )
                case .updated:
                    return Alert(
                                title: Text("Success"),
                                message: Text("Your password has been updated.")
                                )
                case .incorrectPassword:
                    return Alert(
                                title: Text("Incorrect Password"),
                                message: Text("The current password was incorrect.")
                                )
                case .passwordNotFound:
                    return Alert(
                                title: Text("Password Unknown"),
                                message: Text("Couldn't find your account. Double check the current password.")
                            )
                case .passwordsEmpty:
                    return Alert(
                                title: Text("Password Empty"),
                                message: Text("You can't send in an empty password.")
                            )
                default:
                    return Alert(
                                title: Text("Something Went Wrong"),
                                message: Text("Exit and try again.")
                            )
            }
        }
    }
}

extension ChangePassword {
    func updatePassword(newPassword: String, oldPassword: String) {
        UserNetworking().changePassword(newPassword: newPassword, username: user.username, oldPassword: oldPassword, token: user.accessToken, completion: { pStatus in
            switch pStatus{
            case .success(let status):
                if status == .updated {
                    DispatchQueue.main.async {
                        self.passwordState = status
                        self.showAlert = true
                    }
                } else if status == .incorrectPassword {
                    DispatchQueue.main.async {
                        self.passwordState = status
                        self.showAlert = true
                    }
                } else if status == .passwordNotFound {
                    DispatchQueue.main.async {
                        self.passwordState = status
                        self.showAlert = true
                    }
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
    case noActionYet = 3
    case passwordsDontMatch = 4
    case passwordsEmpty = 5
}
