//
//  File.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation

struct Tip: Decodable {
    let person: String
    let saying: String
}

extension Tip {
    
    static let empty = Tip(person: "", saying: "")
}
