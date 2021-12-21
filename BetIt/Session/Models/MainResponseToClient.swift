//
//  MainResponseToClient.swift
//  BetIt
//
//  Created by Asim Brown on 12/20/21.
//

import Foundation
import CloudKit

struct MainResponseToClient<T: Codable>: Codable {
    var dataForClient: T
    var newAccessToken: String?
}
