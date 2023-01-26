//
//  InquiryEtc.swift
//  Cafejari
//
//  Created by 안용우 on 2023/01/23.
//

import Foundation


struct InquiryEtc: Decodable {
    let id: Int
    let content: String
    let answer: String
    let requestDate: String
}
typealias InquiryEtcs = [InquiryEtc]
