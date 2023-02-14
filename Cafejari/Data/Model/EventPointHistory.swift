//
//  EventPointHistory.swift
//  Cafejari
//
//  Created by 안용우 on 2023/02/13.
//

import Foundation


struct EventPointHistory: Decodable {
    let id: Int
    let content: String
    let point: Int
    let time: String
}
typealias EventPointHistories = [EventPointHistory]
