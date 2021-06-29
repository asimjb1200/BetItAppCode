//
//  HasJSONDecoder.swift
//  BetIt
//
//  Created by Asim Brown on 6/29/21.
//

import Foundation

protocol HasJSONDecoder {
    
    static var decoder: JSONDecoder { get }
}

extension HasJSONDecoder {
    
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }
}
