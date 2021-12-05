//
//  global.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation

var NONCE = 1.0

enum Side: String {
    case buy = "buy"
    case sell = "sell"
}

func GenerateOrderID() -> String {
    var rands:[Int] = []
    var hexa:[String] = []
    var id = ""
    
    for i in 0...16 {
        let r = Float.random(in: 0.0...1.0)
        let rand = 4294967296.0 * r
        rands.append((Int(rand) >> ((3 & i) << 3)) & 255)
    }
    
    for i in 0...256 {
        var hex = String(String(format:"%02X", i+256)).trimmingCharacters(in: CharacterSet(charactersIn: "0xL"))
        hex.removeFirst()
        hexa.append(hex)
    }
    
    
    for i in 0...16 {
        id += hexa[rands[i]]
        
        if i % 2 != 0 {
            id += "-"
        }
    }
    
    return id
}
