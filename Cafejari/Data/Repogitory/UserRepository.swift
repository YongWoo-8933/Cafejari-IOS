//
//  UserRepository.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation
import UIKit

protocol UserRepository {
    
    func fetchUser(accessToken: String) async throws -> UserResponse
    func logout(refreshToken: String) async throws
    func putProfile(accessToken: String, profileId: Int, nickname: String?, image: UIImage?) async throws -> UserResponse
    func putFcmToken(accessToken: String, profileId: Int, fcmToken: String) async throws -> UserResponse
    func fetchWeekLeader(accessToken: String) async throws -> [LeaderResponse]
    func fetchMonthLeader(accessToken: String) async throws -> [LeaderResponse]
}


final class UserRepositoryImpl: UserRepository {
    
    @Inject var httpRoute: HttpRoute
    @Inject var customUrlRequest: CustomURLRequest
    
    
    func fetchUser(accessToken: String) async throws -> UserResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.user(), accessToken: accessToken)
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
            } else if httpUrlRes.statusCode == 409 {
                let errorCodeRes = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
                switch errorCodeRes.error_code {
                case 404:
                    throw CustomError.errorMessage("번호 인증을 먼저 진행해주세요")
                default:
                    throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                }
                
            } else if (200..<300).contains(httpUrlRes.statusCode) {
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
    
    func logout(refreshToken: String) async throws {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(urlString: httpRoute.logout(), requestBody: ["refresh" : refreshToken])
            let (_, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if (200..<300).contains(httpUrlRes.statusCode) {
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func putProfile(accessToken: String, profileId: Int, nickname: String?, image: UIImage?) async throws -> UserResponse {
        do {
            let urlSession = URLSession.shared
            var request = URLRequest(url: URL(string: httpRoute.profile(id: profileId))!)
            if let image = image {
                let boundary = "Boundary-\(UUID().uuidString)"
                
                if let imageFile = image.jpegData(compressionQuality: 0.1) {
                    request.httpMethod = "PUT"
                    
                    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                    
                    let body = NSMutableData()
                    let str = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
                    let randomString = "\(str.randomString(9)).jpeg"
                    
                    if let nickname = nickname {
                        body.append("--\(boundary)\r\n".data(using: .utf8)!)
                        body.append("Content-Disposition: form-data; name=\"nickname\"\r\n\r\n".data(using: .utf8)!)
                        body.append("\(nickname)\r\n".data(using: .utf8)!)
                    }
                    
                    body.append("--\(boundary)\r\n".data(using: .utf8)!)
                    body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(randomString)\"\r\n".data(using: .utf8)!)
                    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                    body.append(imageFile)
                    body.append("\r\n".data(using: .utf8)!)
                    
                    body.append("--\(boundary)--".data(using: .utf8)!)
                    
                    request.httpBody = body as Data
                }
            } else {
                request = customUrlRequest.put(
                    urlString: httpRoute.profile(id: profileId),
                    accessToken: accessToken,
                    requestBody: ["nickname" : nickname ?? ""])
            }
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
            } else if httpUrlRes.statusCode == 409 {
                let errorCodeRes = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
                switch errorCodeRes.error_code {
                case 404:
                    throw CustomError.errorMessage("번호 인증을 먼저 진행해주세요")
                default:
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
    
    
    func putFcmToken(accessToken: String, profileId: Int, fcmToken: String) async throws -> UserResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.put(
                urlString: httpRoute.profile(id: profileId),
                accessToken: accessToken,
                requestBody: ["fcm_token": fcmToken]
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
    
    func fetchMonthLeader(accessToken: String) async throws -> [LeaderResponse] {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.monthLeader(), accessToken: accessToken)
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([LeaderResponse].self, from: data)
                
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
    
    func fetchWeekLeader(accessToken: String) async throws -> [LeaderResponse] {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.weekLeader(), accessToken: accessToken)
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([LeaderResponse].self, from: data)
                
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
}
