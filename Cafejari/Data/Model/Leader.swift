//
//  Leader.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/12.
//

import Foundation

struct Leader: Decodable {
    let nickname: String
    let image: String
    let ranking: Int
    let activity: Int
}
extension Leader {
    static var empty = Leader(nickname: "", image: "", ranking: 0, activity: 0)
}
typealias Leaders = [Leader]
