//
//  Item.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/17.
//

import Foundation

struct Item: Decodable {
    let id: Int
    let name: String
    let category: String
    let brand: String
    let image: String
    let price: Int
}

typealias Items = [Item]

extension Item {
    
    static let empty = Item(id: 0, name: "", category: "", brand: "", image: "", price: 0)
}
