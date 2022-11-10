//
//  CafeLogDto.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/25.
//

import Foundation


struct CafeLogResponse: Decodable {
    let id: Int
    let start, finish: String
    let expired, notified: Bool
    let point: Int
    let master: UserResponse
    let cafe: CafeLogCafeResponse
    let cafe_detail_log: CafeDetailLogs
}
extension CafeLogResponse {
    func getCafeLog() -> CafeLog {
        return CafeLog(
            id: self.id,
            cafeId: self.cafe.id,
            name: self.cafe.cafe_info.name,
            latitude: self.cafe.cafe_info.latitude,
            longitude: self.cafe.cafe_info.longitude,
            floor: self.cafe.floor,
            start: self.start,
            finish: self.finish,
            expired: self.expired,
            point: self.point,
            master: CafeMaster(userId: self.master.id, nickname: self.master.profile?.nickname ?? "", grade: self.master.profile?.grade ?? 0),
            cafeDetailLogs: self.cafe_detail_log
        )
    }
}

struct CafeLogCafeResponse: Decodable {
    let id: Int
    let floor: Int
    let cafe_info: CafeLogCafeInfoResponse
}

struct CafeLogCafeInfoResponse: Decodable {
    let id: Int
    let name, city, gu, address: String
    let total_floor, floor: Int
    let latitude, longitude: Double
}

struct AutoExpiredCafeLogResponse: Decodable {
    let id: Int
    let time: String?
    let cafe_log: CafeLogResponse?
}


