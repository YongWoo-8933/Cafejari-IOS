//
//  CafeInfo.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/21.
//

import Foundation

struct CafeInfo: Decodable {
    let id: Int
    let name: String
    let city: String
    let gu: String
    let address: String
    let totalFloor: Int
    let floor: Int
    let latitude: Double
    let longitude: Double
    let googlePlaceId: String
    let cafes: Cafes
}
extension CafeInfo {
    static var empty = CafeInfo(id: 0, name: "", city: "", gu: "", address: "", totalFloor: 1, floor: 1, latitude: 37.0, longitude: 126.0, googlePlaceId: GlobalString.None.rawValue, cafes: [])
}
typealias CafeInfos = [CafeInfo]


struct Cafe: Decodable {
    let id: Int
    let crowded: Int
    let master: CafeMaster
    let floor: Int
    let recentUpdatedLogs: RecentUpdatedLogs
}
extension Cafe {
    static var empty = Cafe(id: 0, crowded: -1, master: CafeMaster.empty, floor: 1, recentUpdatedLogs: [])
}
typealias Cafes = [Cafe]


struct RecentUpdatedLog: Decodable {
    let id: Int
    let master: CafeMaster
    let update: String
    let crowded: Int
}
extension RecentUpdatedLog {
    static var empty = RecentUpdatedLog(id: 0, master: CafeMaster.empty, update: "", crowded: -1)
}
typealias RecentUpdatedLogs = [RecentUpdatedLog]


struct CafeMaster: Decodable {
    let userId: Int
    let nickname: String
    let grade: Int
}
extension CafeMaster {
    static var empty = CafeMaster(userId: 0, nickname: "", grade: 0)
}
