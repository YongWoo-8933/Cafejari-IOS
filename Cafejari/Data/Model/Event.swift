//
//  Event.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/19.
//

import Foundation

struct Event: Decodable {
    let id: Int
    let image: String
    let name: String
    let url: String
    let start: String
    let finish: String
    let preview: String
    let is_posted: Bool
}

typealias Events = [Event]
