//
//  CafeMaster.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/25.
//

import Foundation

struct CafeMaster: Decodable {
    let userId: Int
    let nickname: String
    let grade: Int
}
extension CafeMaster {
    static var empty = CafeMaster(userId: 0, nickname: "", grade: 0)
}
