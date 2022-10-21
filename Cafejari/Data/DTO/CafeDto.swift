//
//  CafeDto.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/21.
//

import Foundation

// cafe info
struct CafeInfoResponse: Decodable {
    let id: Int
    let name: String
    let city: String
    let gu: String
    let address: String
    let total_floor: Int
    let floor: Int
    let latitude: Double
    let longitude: Double
    let google_place_id: String
    let cafe: [CafeInfoCafeResponse]
}

struct CafeInfoCafeResponse: Decodable {
    let id: Int
    let floor: Int
    let master: UserResponse?
    let recent_updated_log: [RecentUpdatedLogResponse]
}

struct RecentUpdatedLogResponse: Decodable {
    let id: Int
    let update: String
    let cafe_detail_log: CafeInfoCafeDetailLog
}

struct CafeInfoCafeDetailLog: Decodable {
    let id: Int
    let crowded: Int
    let cafe_log: CafeInfoCafeLog
}

struct CafeInfoCafeLog: Decodable {
    let id: Int
    let expired: Bool
    let master: UserResponse
}


// cafe log
