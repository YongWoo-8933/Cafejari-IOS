//
//  CustomURLRequest.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/25.
//

import Foundation

struct CustomURLRequest {
    
}


extension CustomURLRequest {
    func get(urlString: String, accessToken: String? = nil) -> URLRequest {
        var request = URLRequest.init(url: URL( string: urlString.getEncodedStringFromKorean() )!, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let accessToken = accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    func post(urlString: String, accessToken: String? = nil, requestBody: Dictionary<String, Any>) -> URLRequest {
        
        var request = URLRequest.init(url: URL( string: urlString )!, timeoutInterval: 10.0)
        let requestData = requestBody
        let requestJson = try! JSONSerialization.data(withJSONObject: requestData, options: [])
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestJson
        
        if let accessToken = accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    func put(urlString: String, accessToken: String? = nil, requestBody: Dictionary<String, Any>) -> URLRequest {
        var request = URLRequest.init(url: URL( string: urlString )!, timeoutInterval: 10.0)
        let requestData = requestBody
        let requestJson = try! JSONSerialization.data(withJSONObject: requestData, options: [])
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestJson
        
        if let accessToken = accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    func delete(urlString: String, accessToken: String? = nil) -> URLRequest {
        var request = URLRequest.init(url: URL( string: urlString )!, timeoutInterval: 10.0)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let accessToken = accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}
