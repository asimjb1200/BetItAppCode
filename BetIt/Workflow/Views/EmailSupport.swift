//
//  EmailSupport.swift
//  BetIt
//
//  Created by Asim Brown on 12/13/21.
//

import SwiftUI

struct EmailSupport: View {
    @StateObject var viewModel: EmailSupportViewModel = EmailSupportViewModel()
    @EnvironmentObject var user: UserModel
    init() {
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.emailSent == false {
                Text("Send Us A Message:").font(.custom("MontserratAlternates-ExtraBold", size: 20)).frame(maxWidth: .infinity)
                TextField("Subject:", text: $viewModel.subjectLine)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                            .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.694, opacity: 0.763))
                    )
                    .padding()

                TextEditor(text: $viewModel.message)
                    .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.694, opacity: 0.763))
                    .cornerRadius(25.0)
                    .padding()
                    .frame(height: 200, alignment: .center)

                Button("Send Email") {
                    guard
                        !viewModel.subjectLine.isEmpty, !viewModel.message.isEmpty
                    else {
                        // add in an alert to make sure they can't send in an empty email
                        return
                    }
                    viewModel.sendEmail(token: user.accessToken)
                }
                .foregroundColor(Color("Accent2"))
                
            } else {
                Text("Your email was delivered").font(.custom("MontserratAlternates-ExtraBold", size: 28))
                Text("We will be in touch within 2-3 business days.").font(.custom("MontserratAlternates-Regular", size: 20))
            }
        }
        .onDisappear(){
            print("Email support view is going away")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

struct EmailSupport_Previews: PreviewProvider {
    static var previews: some View {
        EmailSupport()
    }
}
