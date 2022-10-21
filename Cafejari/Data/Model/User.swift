//
//  User.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation

struct User: Decodable {
    let userId: Int
    let profileId: Int
    let dateJoined: String
    let email: String
    let lastLogin: String
    let authorization: Bool
    let nickname: String
    let fcmToken: String
    let phoneNumber: String
    let image: String
    let point: Int
    let grade: Int
    let activity: Int
}

extension User {
    
    static let empty = User(userId: 0, profileId: 0, dateJoined: "", email: "", lastLogin: "", authorization: false, nickname: "", fcmToken: "", phoneNumber: "00000000", image: "", point: 0, grade: 0, activity: 0)
}
