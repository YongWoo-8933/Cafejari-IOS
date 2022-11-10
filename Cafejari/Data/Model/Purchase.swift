//
//  Purchase.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/31.
//

import Foundation

struct Purchase: Decodable {
    let id: Int
    let time: String
    let state: Int
    let item: Item
}

typealias Purchases = [Purchase]

extension Purchase {
    static let empty = Purchase(id: 0, time: "", state: 0, item: Item.empty)
}
