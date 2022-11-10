//
//  ErrorResponse.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/30.
//

import Foundation

struct ErrorCodeResponse: Decodable {
    let error_code: Int
}

struct ErrorCodeWithDetailResponse: Decodable {
    let error_code: Int
    let detail: String
}

struct TokenExpiredErrorResponse: Decodable {
    let detail: String
    let code: String
}

struct NicknameErrorResponse: Decodable {
    let nickname: [String]
}

struct PhoneNumberErrorResponse: Decodable {
    let phone_number: [String]
}

struct NicknamePhoneNumberErrorResponse: Decodable {
    let nickname: [String]
    let phone_number: [String]
}
