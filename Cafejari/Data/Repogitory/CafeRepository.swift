//
//  CafeRepository.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/21.
//

import Foundation

protocol CafeRepository {
    
    func fetchCafeInfos(accessToken: String, latitude: Double, longitude: Double, zoomLevel: Int) async throws -> [CafeInfoResponse]
    func fetchExpiredCafeLogs(accessToken: String) async throws -> [CafeLogResponse]
    func registerMaster(accessToken: String, cafeId: Int, crowded: Int) async throws -> CafeLogResponse
    func putCrowded(accessToken: String, cafeLogId: Int, crowded: Int) async throws -> CafeLogResponse
    func deleteCafeDetailLog(accessToken: String, cafeDetailLogId: Int) async throws -> CafeLogResponse
    func expireMaster(accessToken: String, cafeLogId: Int, adWatched: Bool) async throws -> CafeLogResponse
    func addAdPoint(accessToken: String, cafeLogId: Int) async throws -> UserResponse
    func fetchUnExpiredCafeLog(accessToken: String) async throws -> [CafeLogResponse]
    func fetchAutoExpiredCafeLog(accessToken: String) async throws -> AutoExpiredCafeLogResponse
    func deleteAutoExpiredCafeLog(accessToken: String, autoExpiredCafeLogId: Int) async throws
    func thumbsUp(accessToken: String, recentLogId: Int, isAdWatched: Bool) async throws -> UserResponse
    func search(query: String) async throws -> [CafeInfoRepresentationResponse]
}


final class CafeRepositoryImpl: CafeRepository {
    
    @Inject var httpRoute: HttpRoute
    @Inject var customUrlRequest: CustomURLRequest
    
    func fetchCafeInfos(accessToken: String, latitude: Double, longitude: Double, zoomLevel: Int) async throws -> [CafeInfoResponse] {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.cafeInfo(lat: latitude, lng: longitude, zoomLevel: zoomLevel), accessToken: accessToken)
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
            } else if (200..<300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([CafeInfoResponse].self, from: data)
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.accessTokenExpired {
            throw CustomError.accessTokenExpired
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func fetchExpiredCafeLogs(accessToken: String) async throws -> [CafeLogResponse] {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.cafeLog(expired: true), accessToken: accessToken)
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
            } else if (200..<300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([CafeLogResponse].self, from: data)
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.accessTokenExpired {
            throw CustomError.accessTokenExpired
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func registerMaster(accessToken: String, cafeId: Int, crowded: Int) async throws -> CafeLogResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.masterRegistration(),
                accessToken: accessToken,
                requestBody: ["cafe_id": cafeId, "crowded": crowded]
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if httpUrlRes.statusCode == 409 {
                let errorCodeRes = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
                switch errorCodeRes.error_code {
                case 100:
                    throw CustomError.errorMessage("이미 다른 마스터가 활동중입니다")
                case 102:
                    let errorCodeWithDetailRes = try JSONDecoder().decode(ErrorCodeWithDetailResponse.self, from: data)
                    throw CustomError.errorMessage("지금은 마스터 활동 제한시간입니다(\(errorCodeWithDetailRes.detail))")
                default:
                    throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                }
                
            } else if (200..<300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(CafeLogResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
            
        } catch CustomError.accessTokenExpired {
            throw CustomError.accessTokenExpired
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func putCrowded(accessToken: String, cafeLogId: Int, crowded: Int) async throws -> CafeLogResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.put(
                urlString: httpRoute.crowded(),
                accessToken: accessToken,
                requestBody: ["cafe_log_id": cafeLogId, "crowded": crowded]
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if httpUrlRes.statusCode == 409 {
                let errorCodeRes = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
                switch errorCodeRes.error_code {
                case 101:
                    throw CustomError.masterExpired
                case 102:
                    let errorCodeWithDetailRes = try JSONDecoder().decode(ErrorCodeWithDetailResponse.self, from: data)
                    throw CustomError.errorMessage("지금은 마스터 활동 제한시간입니다(\(errorCodeWithDetailRes.detail))")
                default:
                    throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                }
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(CafeLogResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
            
        } catch CustomError.accessTokenExpired {
            throw CustomError.accessTokenExpired
        } catch CustomError.masterExpired {
            throw CustomError.masterExpired
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func deleteCafeDetailLog(accessToken: String, cafeDetailLogId: Int) async throws -> CafeLogResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.delete (
                urlString: httpRoute.cafeDetailLog(id: cafeDetailLogId),
                accessToken: accessToken
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(CafeLogResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
            
        } catch CustomError.accessTokenExpired {
            throw CustomError.accessTokenExpired
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func expireMaster(accessToken: String, cafeLogId: Int, adWatched: Bool) async throws -> CafeLogResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.masterExpiration(),
                accessToken: accessToken,
                requestBody: ["cafe_log_id": cafeLogId, "ad_multiple_applied": adWatched]
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if httpUrlRes.statusCode == 409 {
                let errorCodeRes = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
                if errorCodeRes.error_code == 101 {
                    throw CustomError.masterExpired
                }
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(CafeLogResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
            
        } catch CustomError.accessTokenExpired {
            throw CustomError.accessTokenExpired
        } catch CustomError.masterExpired {
            throw CustomError.masterExpired
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func addAdPoint(accessToken: String, cafeLogId: Int) async throws -> UserResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.adPoint(),
                accessToken: accessToken,
                requestBody: ["cafe_log_id": cafeLogId]
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(UserResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
            
        } catch CustomError.accessTokenExpired {
            throw CustomError.accessTokenExpired
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func fetchUnExpiredCafeLog(accessToken: String) async throws -> [CafeLogResponse] {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.cafeLog(expired: false), accessToken: accessToken)
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([CafeLogResponse].self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
            
        } catch CustomError.accessTokenExpired {
            throw CustomError.accessTokenExpired
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func fetchAutoExpiredCafeLog(accessToken: String) async throws -> AutoExpiredCafeLogResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.autoExpiredCafeLog(), accessToken: accessToken)
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(AutoExpiredCafeLogResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
            
        } catch CustomError.accessTokenExpired {
            throw CustomError.accessTokenExpired
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func deleteAutoExpiredCafeLog(accessToken: String, autoExpiredCafeLogId: Int) async throws {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.delete(
                urlString: httpRoute.deleteAutoExpiredCafeLog(id: autoExpiredCafeLogId), accessToken: accessToken)
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
            
        } catch CustomError.accessTokenExpired {
            throw CustomError.accessTokenExpired
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    
    func thumbsUp(accessToken: String, recentLogId: Int, isAdWatched: Bool) async throws -> UserResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.thumbsUp(),
                accessToken: accessToken,
                requestBody: ["recent_log_id": recentLogId, "ad_thumbs_up": isAdWatched]
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if httpUrlRes.statusCode == 409 {
                let errorCodeRes = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
                if errorCodeRes.error_code == 200 {
                    throw CustomError.errorMessage("자신의 활동은 추천할 수 없습니다")
                } else if errorCodeRes.error_code == 201 {
                    throw CustomError.errorMessage("이미 추천한 활동입니다")
                } else if errorCodeRes.error_code == 202 {
                    throw CustomError.errorMessage("해당 활동은 더이상 추천할 수 없습니다")
                } else {
                    throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                }
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(UserResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
            
        } catch CustomError.accessTokenExpired {
            throw CustomError.accessTokenExpired
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    
    func search(query: String) async throws -> [CafeInfoRepresentationResponse] {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(
                urlString: httpRoute.search(query: query)
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([CafeInfoRepresentationResponse].self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
            
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
}
