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

struct PreAuthResponse: Decodable {
    let nickname: String
    let phone_number: String
}

struct RecommendResponse: Decodable {
    let nickname: String
}

struct KakaoLoginResponse: Decodable {
    let access_token: String
    let is_user_exist: Bool
}

struct GoogleLoginResponse: Decodable {
    let access_token: String
    let code: String
    let is_user_exist: Bool
}

struct AppleLoginResponse: Decodable {
    let id_token: String
    let code: String
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
extension UserResponse {
    func getUser() -> User {
        let profile = self.profile ?? ProfileResponse.empty
        
        return User(
            userId: self.id,
            profileId: profile.id,
            dateJoined: self.date_joined,
            email: self.email,
            lastLogin: self.last_login,
            authorization: self.authorization,
            nickname: profile.nickname ?? "",
            fcmToken: profile.fcm_token,
            phoneNumber: profile.phone_number ?? "00000000",
            image: profile.image,
            point: profile.point,
            grade: profile.grade,
            activity: profile.activity
        )
    }
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
    static let empty = ProfileResponse(id: 0, nickname: "", fcm_token: String.None, phone_number: "00000000", image: "", point: 0, grade: 0, activity: 0)
}

struct SocialUserTypeResponse: Decodable {
    let type: String
}

struct LeaderResponse: Decodable {
    let id: Int
    let user: UserResponse
    let ranking: Int
    let activity: Int
}
extension LeaderResponse {
    func getLeader() -> Leader {
        return Leader(
            nickname: self.user.profile?.nickname ?? "",
            image: self.user.profile?.image ?? "",
            ranking: self.ranking,
            activity: self.activity
        )
    }
}
