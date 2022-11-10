//
//  HttpError.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/07.
//

import Foundation

func nsErrorHandle(_ error: NSError) -> CustomError {
    switch error.code {
    case -999:
        return CustomError.errorMessage("데이터 로드 취소됨")
    case -1001:
        return CustomError.errorMessage("시간 초과. 네트워크 연결을 확인해주세요")
    case -1009:
        return CustomError.errorMessage("네트워크 연결이 원활하지 않습니다")
    case -1020:
        return CustomError.errorMessage("네트워크 연결을 확인해주세요")
    default:
        return CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
    }
}

enum CustomError: Error {
    case accessTokenExpired, refreshTokenExpired, masterExpired
    case errorMessage(_ message: String)
}
