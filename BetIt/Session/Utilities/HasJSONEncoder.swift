//
//  HasJSONEncoder.swift
//  BetIt
//
//  Created by Asim Brown on 6/29/21.
//

import Foundation

protocol HasJSONEncoder {
    
    static var encoder: JSONEncoder { get }
}

extension HasJSONEncoder {
    
    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        return encoder
    }
}
