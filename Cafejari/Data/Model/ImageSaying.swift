//
//  ImageSaying.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/25.
//

import Foundation

struct ImageSaying: Decodable {
    let image: String
    let person: String
    let saying: String
}

extension ImageSaying {
    
    static let empty = ImageSaying(image: "", person: "", saying: "")
}
