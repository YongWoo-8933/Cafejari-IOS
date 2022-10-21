//
//  UserResponse.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation

struct AccessTokenResponse: Decodable {
    let access: String
    let access_token_expiration: String
}

struct KakaoLoginResponse: Decodable {
    let access_token: String
    let is_user_exist: Bool
}

struct LoginResponse: Decodable {
    let access_token: String
    let refresh_token: String
    let user: UserResponse
}

struct UserResponse: Decodable {
    let id: Int
    let last_login: String
    let date_joined: String
    let email: String
    let authorization: Bool
    let profile: ProfileResponse?
}

struct ProfileResponse: Decodable {
    let id: Int
    let nickname: String?
    let fcm_token: String
    let phone_number: String?
    let image: String
    let point: Int
    let grade: Int
    let activity: Int
}

extension ProfileResponse {
    static let empty = ProfileResponse(id: 0, nickname: "", fcm_token: GlobalString.None.rawValue, phone_number: "00000000", image: "", point: 0, grade: 0, activity: 0)
}
