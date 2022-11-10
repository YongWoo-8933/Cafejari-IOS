//
//  InformationDto.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/28.
//

import Foundation

struct PointPolicyResponse: Decodable {
    let image: String
    let order: Int
    let sub_title: String
    let sub_content: String
}

struct CautionResponse: Decodable {
    let order: Int
    let sub_title: String
    let sub_content: String
}

struct FAQResponse: Decodable {
    let order: Int
    let question: String
    let answer: String
}
