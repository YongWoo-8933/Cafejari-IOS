//
//  File.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation

struct ImageSaying: Decodable {
    let person: String
    let saying: String
    var image: String? = ""
}

extension ImageSaying {
    
    static let empty = ImageSaying(person: "", saying: "")
}
