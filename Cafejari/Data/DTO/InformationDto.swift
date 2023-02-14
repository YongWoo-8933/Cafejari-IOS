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

struct EventPointHistoryResponse: Decodable {
    let id: Int
    let content: String
    let point: Int
    let time: String
}
