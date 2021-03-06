//
//  ChangeEmail.swift
//  BetIt
//
//  Created by Asim Brown on 8/4/21.
//

import SwiftUI

struct ChangeEmail: View {
    @EnvironmentObject private var user: UserModel
    @State private var emailAddress = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var emailState: EmailStates = .noActionYet
    private var userService: UserNetworking = .shared
    var body: some View {
        VStack {
            SecureField("", text: $password)
                .padding(.vertical)
                .placeholder(when: password.isEmpty) {
                    Text("Enter Password").customTextStyleOne()
                }.background(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                        .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.694, opacity: 0.763)).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                )
                .padding()
            
            TextField("", text: $emailAddress)
                .padding(.vertical)
                .placeholder(when: emailAddress.isEmpty) {
                    Text("New Email").customTextStyleOne()
                }.background(
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                        .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.694, opacity: 0.763)).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                )
                .padding()
            
            
            Button("Save Email") {
                guard
                    !emailAddress.isEmpty,!password.isEmpty,
                    !emailAddress.trimmingCharacters(in: .whitespaces).isEmpty,
                    !password.trimmingCharacters(in: .whitespaces).isEmpty
                else {
                    emailState = .passwordOrEmailEmpty
                    return
                }
                self.updateEmail(username: user.username, password: password)
            }
            .padding(.all)
            .foregroundColor(.white)
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    LinearGradient(gradient: Gradient(colors: [Color("Accent"), Color("Accent2")]), startPoint: .leading, endPoint: .trailing)
                )
        )
        .alert(isPresented: $showAlert) {
            switch emailState {
                case .updated:
                    return Alert(
                                title: Text("Success"),
                                message: Text("Your email has been updated.")
                                )
                case .incorrectPassword:
                    return Alert(
                                title: Text("Incorrect Password"),
                                message: Text("The password entered was incorrect.")
                                )
                case .usernameNotFound:
                    return Alert(
                                title: Text("Username Unknown"),
                                message: Text("Couldn't find your account.")
                            )
                case .passwordOrEmailEmpty:
                    return Alert(
                                title: Text("Empty Field"),
                                message: Text("Make sure you aren't sending in spaces only for the email or password.")
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

extension ChangeEmail {
    func updateEmail(username: String, password: String) {
        userService.changeEmail(username: username, password: self.password, email: self.emailAddress, token: user.accessToken, completion: {emailState in
            switch emailState {
            case .success(let status):
                if status == .updated {
                    DispatchQueue.main.async {
                        self.emailState = status
                        self.showAlert = true
                    }
                } else if status == .incorrectPassword {
                    DispatchQueue.main.async {
                        self.emailState = status
                        self.showAlert = true
                    }
                } else if status == .usernameNotFound {
                    DispatchQueue.main.async {
                        self.emailState = status
                        self.showAlert = true
                    }
                }
            case .failure(let err):
                print(err)
            }
        })
    }
}

struct ChangeEmail_Previews: PreviewProvider {
    static var previews: some View {
        ChangeEmail()
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
