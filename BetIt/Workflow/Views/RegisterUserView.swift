//
//  RegisterUserView.swift
//  BetIt
//
//  Created by Asim Brown on 9/4/21.
//

import SwiftUI

struct RegisterUserView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var password: String = ""
    @State var email: String = ""
    @State var username: String = ""
    @State var showAlert: Bool = false
    @State var userSuccessfullyCreated = false;
    var body: some View {
        VStack {
            TextField("Username:", text: $username)
                .padding(.vertical)
                .placeholder(when: username.isEmpty) {
                    Text("Username: ").foregroundColor(.white)
                }
            TextField("Email:", text: $email)
                .padding(.vertical)
                .placeholder(when: email.isEmpty) {
                    Text("Email:").foregroundColor(.white)
                }
            SecureField("Password:", text: $password)
                .padding(.vertical)
                .placeholder(when: password.isEmpty) {
                    Text("Enter Password").foregroundColor(.white)
                }
            
            Button("Register") {
                // check each field for whitespaces
                guard
                    !email.isEmpty, !email.trimmingCharacters(in: .whitespaces).isEmpty,
                    !username.isEmpty, !username.trimmingCharacters(in: .whitespaces).isEmpty,
                    !password.isEmpty, !password.trimmingCharacters(in: .whitespaces).isEmpty
                else {
                    return
                }
                
                
                UserNetworking().registerUser(username: username.trimmingCharacters(in: .whitespacesAndNewlines), password: password.trimmingCharacters(in: .whitespacesAndNewlines), email: email.trimmingCharacters(in: .whitespacesAndNewlines), completion: { userWasCreatedResponse in
                    switch userWasCreatedResponse {
                        case .success(_):
                            DispatchQueue.main.async {
                                userSuccessfullyCreated.toggle()
                                showAlert.toggle()
                            }
                        case .failure(let err):
                            DispatchQueue.main.async {
                                showAlert.toggle()
                            }
                    }
                })
            }.foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .fill(Color("Accent2"))
        )
        .alert(isPresented: $showAlert) {
            if userSuccessfullyCreated {
                return Alert(title: Text("Success"), message: Text("You are registered. Go back and login now."), dismissButton: .destructive(Text("OK"), action: goBack))
            } else {
                return Alert(title: Text("Something Went Wrong"), message: Text("There was a problem creating your profile. Try again in a few."), dismissButton: .default(Text("OK")))            }
        }
    }
}

extension RegisterUserView {
    func goBack() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct RegisterUserView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterUserView()
    }
}
