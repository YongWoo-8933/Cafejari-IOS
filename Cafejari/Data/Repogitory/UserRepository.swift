//
//  UserRepository.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation

protocol UserRepository {
    
    func requestKakaoLogin(accessToken: String) async throws -> KakaoLoginResponse
    func requestKakaoLoginFinish(accessToken: String) async throws -> LoginResponse
    func makeNewProfile(accessToken: String, userId: Int) async throws -> UserResponse
    func sendSms(accessToken: String, phoneNumber: String) async throws
    func authSms(accessToken: String, authNumber: String, phoneNumber: String) async throws
    func authorize(accessToken: String, profileId: Int, nickname: String, phoneNumber: String) async throws -> UserResponse
    
    func fetchUser(accessToken: String) async throws -> UserResponse
}


final class UserRepositoryImpl: UserRepository {
    
    @Inject var httpRoute: HttpRoute
    
    func requestKakaoLogin(accessToken: String) async throws -> KakaoLoginResponse {
        let urlSession = URLSession.shared
        var request = URLRequest.init(url: URL( string: httpRoute.kakaoLogin() )!)
        let requestData = ["access_token" : accessToken]
        let requestJson = try! JSONSerialization.data(withJSONObject: requestData, options: [])
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = requestJson
        
        let (data, _) = try await urlSession.data(for: request)
        return try JSONDecoder().decode(KakaoLoginResponse.self, from: data)
    }
    
    func requestKakaoLoginFinish(accessToken: String) async throws -> LoginResponse {
        let urlSession = URLSession.shared
        var request = URLRequest.init(url: URL( string: httpRoute.kakaoLoginFinish() )!)
        let requestData = ["access_token" : accessToken, "code": ""]
        let requestJson = try! JSONSerialization.data(withJSONObject: requestData, options: [])
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = requestJson
        
        let (data, _) = try await urlSession.data(for: request)
        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }
    
    
    func makeNewProfile(accessToken: String, userId: Int) async throws -> UserResponse {
        let urlSession = URLSession.shared
        var request = URLRequest.init(url: URL( string: httpRoute.makeNewProfile() )!)
        let requestData = ["user" : userId]
        let requestJson = try! JSONSerialization.data(withJSONObject: requestData, options: [])
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = requestJson
        
        let (data, _) = try await urlSession.data(for: request)
        return try JSONDecoder().decode(UserResponse.self, from: data)
    }
    
    func sendSms(accessToken: String, phoneNumber: String) async throws {
        let urlSession = URLSession.shared
        var request = URLRequest.init(url: URL( string: httpRoute.smsSend() )!)
        let requestData = ["phone_number" : phoneNumber]
        let requestJson = try! JSONSerialization.data(withJSONObject: requestData, options: [])
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = requestJson
        
        try await urlSession.data(for: request)
    }
    
    func authSms(accessToken: String, authNumber: String, phoneNumber: String) async throws {
        let urlSession = URLSession.shared
        var request = URLRequest.init(url: URL( string: httpRoute.smsAuth() )!)
        let requestData = ["phone_number" : phoneNumber, "auth_number": authNumber]
        let requestJson = try! JSONSerialization.data(withJSONObject: requestData, options: [])
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = requestJson
        
        try await urlSession.data(for: request)
    }
    
    func authorize(accessToken: String, profileId: Int, nickname: String, phoneNumber: String) async throws -> UserResponse {
        let urlSession = URLSession.shared
        var request = URLRequest.init(url: URL( string: httpRoute.authorization(profileId: profileId) )!)
        let requestData = ["phone_number" : phoneNumber, "nickname": nickname]
        let requestJson = try! JSONSerialization.data(withJSONObject: requestData, options: [])
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = requestJson
        
        let (data, _) = try await urlSession.data(for: request)
        return try JSONDecoder().decode(UserResponse.self, from: data)
    }
    
    func fetchUser(accessToken: String) async throws -> UserResponse {
        let urlSession = URLSession.shared
        var request = URLRequest.init(url: URL( string: httpRoute.user() )!)
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let (data, _) = try await urlSession.data(for: request)
        return try JSONDecoder().decode(UserResponse.self, from: data)
    }
}
