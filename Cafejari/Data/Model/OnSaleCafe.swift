//
//  OnSaleCafe.swift
//  Cafejari
//
//  Created by 안용우 on 2023/01/23.
//

import Foundation


struct OnSaleCafe: Decodable {
    let order: Int
    let content: String
    let image: String
    let distance: Int
    let cafeInfoId: Int
    let cafeInfoName: String
    let cafeInfoCity: String
    let cafeInfoGu: String
    let cafeInfoAddress: String
    let cafeInfoLatitude: Double
    let cafeInfoLongitude: Double
}
typealias OnSaleCafes = [OnSaleCafe]

extension OnSaleCafe {
    func copy(
        order: Int? = nil,
        content: String? = nil,
        image: String? = nil,
        distance: Int? = nil,
        cafeInfoId: Int? = nil,
        cafeInfoName: String? = nil,
        cafeInfoCity: String? = nil,
        cafeInfoGu: String? = nil,
        cafeInfoAddress: String? = nil,
        cafeInfoLatitude: Double? = nil,
        cafeInfoLongitude: Double? = nil
    ) -> OnSaleCafe {
        return OnSaleCafe(
            order: order ?? self.order,
            content: content ?? self.content,
            image: image ?? self.image,
            distance: distance ?? self.distance,
            cafeInfoId: cafeInfoId ?? self.cafeInfoId,
            cafeInfoName: cafeInfoName ?? self.cafeInfoName,
            cafeInfoCity: cafeInfoCity ?? self.cafeInfoCity,
            cafeInfoGu: cafeInfoGu ?? self.cafeInfoGu,
            cafeInfoAddress: cafeInfoAddress ?? self.cafeInfoAddress,
            cafeInfoLatitude: cafeInfoLatitude ?? self.cafeInfoLatitude,
            cafeInfoLongitude: cafeInfoLongitude ?? self.cafeInfoLongitude
        )
    }
}
