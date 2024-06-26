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
    let moreInfo: MoreInfo
}
extension CafeInfo {
    static var empty = CafeInfo(id: 0, name: "", city: "", gu: "", address: "", totalFloor: 1, floor: 1, latitude: 37.0, longitude: 126.0, googlePlaceId: String.None, cafes: [], moreInfo: MoreInfo.empty)
    
    func getMinCrowded() -> Int {
        var minCrowded = -1
        self.cafes.forEach { cafe in
            if cafe.crowded != -1 {
                if minCrowded == -1 {
                    minCrowded = cafe.crowded
                } else {
                    if minCrowded > cafe.crowded {
                        minCrowded = cafe.crowded
                    }
                }
            }
        }
        return minCrowded
    }
    
    func isMasterAvailable() -> Bool {
        var available = false
        self.cafes.forEach { cafe in
            if cafe.isMasterAvailable() {
                available = true
            }
        }
        return available
    }
    
    func masterAvailableFloors() -> [Int] {
        var masterAvailableFloors: [Int] = []
        self.cafes.forEach { cafe in
            if cafe.isMasterAvailable() {
                masterAvailableFloors.append(cafe.floor)
            }
        }
        return masterAvailableFloors
    }
    
    func isAssociated() -> Bool {
        return self.moreInfo.id != 0
    }
    
    func getRestroomInfoExistCafes() -> Cafes {
        var res: Cafes = []
        self.cafes.forEach { cafe in
            if cafe.hasRestroomInfo() {
                res.append(cafe)
            }
        }
        return res
    }
    
    func getWallSocketInfoExistCafes() -> Cafes {
        var res: Cafes = []
        self.cafes.forEach { cafe in
            if cafe.hasWallSocketInfo() {
                res.append(cafe)
            }
        }
        return res
    }
}
typealias CafeInfos = [CafeInfo]


struct Cafe: Decodable {
    let id: Int
    let crowded: Int
    let master: CafeMaster
    let floor: Int
    let restroom: String
    let wallSocket: String
    let recentUpdatedLogs: RecentUpdatedLogs
}
extension Cafe {
    static var empty = Cafe(id: 0, crowded: -1, master: CafeMaster.empty, floor: 1, restroom: "", wallSocket: "" ,recentUpdatedLogs: [])
    
    func hasRestroomInfo() -> Bool {
        return !self.restroom.isEmpty
    }
    func hasWallSocketInfo() -> Bool {
        return !self.wallSocket.isEmpty
    }
    func isMasterAvailable() -> Bool {
        return self.master.userId == 0
    }
    func hasRecentLog() -> Bool {
        return !self.recentUpdatedLogs.isEmpty
    }
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


struct MoreInfo: Decodable {
    let id: Int
    let event1: String
    let event2: String
    let event3: String
    let image: String
    let notice1: String
    let notice2: String
    let notice3: String
}
extension MoreInfo {
    static var empty = MoreInfo(id: 0, event1: String.None, event2: String.None, event3: String.None, image: String.None, notice1: String.None, notice2: String.None, notice3: String.None)
}
typealias MoreInfos = [MoreInfo]
