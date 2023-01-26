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
    let cafeInfoId: Int
    let cafeInfoName: String
    let cafeInfoCity: String
    let cafeInfoGu: String
    let cafeInfoAddress: String
    let cafeInfoLatitude: Double
    let cafeInfoLongitude: Double
}
typealias OnSaleCafes = [OnSaleCafe]
