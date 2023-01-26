//
//  Version.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/28.
//

import Foundation

struct Version: Decodable {
    let release: Int
    let major: Int
    let minor: Int
}
extension Version {
    static var current = Version(release: 1, major: 2, minor: 1)
}
