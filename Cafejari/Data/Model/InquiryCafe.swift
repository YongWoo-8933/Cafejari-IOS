//
//  InquiryCafe.swift
//  Cafejari
//
//  Created by 안용우 on 2023/01/23.
//

import Foundation


struct InquiryCafe: Decodable {
    let id: Int
    let name: String
    let address: String
    let result: String
    let requestDate: String
}
typealias InquiryCafes = [InquiryCafe]
