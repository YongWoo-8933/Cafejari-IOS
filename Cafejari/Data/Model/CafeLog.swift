//
//  CafeLog.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/25.
//

import Foundation

struct CafeLog: Decodable {
    let id: Int
    let cafeId: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let floor: Int
    let start, finish: String
    let expired: Bool
    let point: Int
    let master: CafeMaster
    let cafeDetailLogs: CafeDetailLogs
}
extension CafeLog {
    static var empty = CafeLog(id: 0, cafeId: 0, name: "", latitude: 37.0, longitude: 127.0, floor: 1, start: "", finish: "", expired: true, point: 0, master: CafeMaster.empty, cafeDetailLogs: [])
}
typealias CafeLogs = [CafeLog]


struct CafeDetailLog: Decodable {
    let id: Int
    let update: String
    let crowded: Int
}
extension CafeDetailLog {
    static var empty = CafeDetailLog(id: 0, update: "", crowded: -1)
}
typealias CafeDetailLogs = [CafeDetailLog]


struct DateCafeLog {
    let date: Date
    let cafeLogs: CafeLogs
}
typealias DateCafeLogs = [DateCafeLog]


struct AutoExpiredCafeLog {
    let id: Int
    let time: String
    let cafeLog: CafeLog
}
