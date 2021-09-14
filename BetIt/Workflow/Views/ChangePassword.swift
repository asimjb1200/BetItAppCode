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
            SecureField("", text: $currentPassword)
                .padding()
                .placeholder(when: currentPassword.isEmpty) {
                    Text("Old Password").customTextStyleOne()
                }
                .background(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                        .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.694, opacity: 0.763)).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                )
                .padding()
            
            SecureField("", text: $newPassword)
                .padding()
                .placeholder(when: newPassword.isEmpty) {
                    Text("New Password").customTextStyleOne()
                }
                .background(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                        .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.694, opacity: 0.763)).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                )
                .padding()
            
            SecureField("", text: $newPasswordAgain)
                .padding()
                .placeholder(when: newPasswordAgain.isEmpty) {
                    Text("Enter New Password Again").customTextStyleOne()
                }
                .background(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                        .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.694, opacity: 0.763)).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                )
                .padding()
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
            
            
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    LinearGradient(gradient: Gradient(colors: [Color("Accent2"), Color("Accent")]), startPoint: .leading, endPoint: .trailing)
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

extension Text {
    func customTextStyleOne() -> some View {
        self.font(.custom("MontserratAlternates-Regular", size: 15)).foregroundColor(Color.white).padding(.leading)
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
