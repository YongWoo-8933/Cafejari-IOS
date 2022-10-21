//
//  CafeRepository.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/21.
//

import Foundation

protocol CafeRepository {
    
    func fetchCafeInfos(accessToken: String) async throws -> [CafeInfoResponse]
    
}


final class CafeRepositoryImpl: CafeRepository {
    
    @Inject var httpRoute: HttpRoute
    
    func fetchCafeInfos(accessToken: String) async throws -> [CafeInfoResponse] {
        let urlSession = URLSession.shared
        var request = URLRequest.init(url: URL( string: httpRoute.cafeInfo() )!)
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        let (data, _) = try await urlSession.data(for: request)
        return try JSONDecoder().decode([CafeInfoResponse].self, from: data)
    }
}
