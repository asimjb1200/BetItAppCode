//
//  NetworkingHelper.swift
//  BetIt
//
//  Created by Asim Brown on 6/24/21.
//

import Foundation

class Networker {
    static let shared = Networker()
    private init() {}
    func constructRequest(uri: String, token: String = "", post: Bool = false) -> URLRequest {
        let url = URL(string: uri)!

        var request: URLRequest = URLRequest(url: url)
        
        if post {
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
    
    func buildReqBody(req: URLRequest, body: [String:Any]) -> URLRequest {
        var request = req
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = bodyData
        } catch let err {
            print(err)
        }
        return request
    }
    
    func checkOkStatus(res: HTTPURLResponse) -> Bool {
        if (200...299).contains(res.statusCode) {
            return true
        } else {
            return false
        }
    }
    
    func check404Status(res: HTTPURLResponse) -> Bool {
        if res.statusCode == 404 {
            return true
        } else {
            return false
        }
    }
}

