//
//  InformationDto.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/28.
//

import Foundation

struct FAQResponse: Decodable {
    let order: Int
    let question: String
    let answer: String
}

struct PopUpNotificationResponse: Decodable {
    let order: Int
    let url: String
    let image: String
    let cafe_info: CafeInfoRepresentationResponse?
}

struct OnSaleCafeResponse: Decodable {
    let order: Int
    let content: String
    let image: String
    let cafe_info: CafeInfoRepresentationResponse
}

struct CafeInfoRepresentationResponse: Decodable {
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
}
extension CafeInfoRepresentationResponse {
    func getCafeInfo() -> CafeInfo {
        return CafeInfo(
            id: self.id,
            name: self.name,
            city: self.city,
            gu: self.gu,
            address: self.address,
            totalFloor: self.total_floor,
            floor: self.floor,
            latitude: self.latitude,
            longitude: self.longitude,
            googlePlaceId: self.google_place_id,
            cafes: [],
            moreInfo: MoreInfo.empty
        )
    }
}

struct InquiryCafeResponse: Decodable {
    let id: Int
    let cafe_name: String
    let cafe_address: String
    let result: String?
    let time: String
}

struct InquiryEtcResponse: Decodable {
    let id: Int
    let content: String
    let answer: String?
    let time: String
}

struct InquiryCafeAdditionalInfoResponse: Decodable {
    let id: Int
    let cafe_info: Int
    let store_information: String
    let opening_hour: String
    let wall_socket: String
    let restroom: String
}

struct EventPointHistoryResponse: Decodable {
    let id: Int
    let content: String
    let point: Int
    let time: String
}
