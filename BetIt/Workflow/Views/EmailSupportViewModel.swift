//
//  EmailSupportViewModel.swift
//  BetIt
//
//  Created by Asim Brown on 12/13/21.
//

import Foundation
final class EmailSupportViewModel: ObservableObject {
    var subjectLine = ""
    var message = ""
    @Published var emailSent: Bool = false
    
    func sendEmail(token: String) {
        UserNetworking().emailSupport(subject: self.subjectLine, message: self.message, token: token, completion: {(emailSentResponse) in
            switch (emailSentResponse) {
            case .success(_):
                    DispatchQueue.main.async {
                        self.emailSent = true
                    }
                case .failure(let err):
                    print(err.localizedDescription)
            }
        })
    }
    
    deinit {
        print("[x] destroyed")
    }
}
