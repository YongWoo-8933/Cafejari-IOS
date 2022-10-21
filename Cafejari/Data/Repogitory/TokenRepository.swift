//
//  TokenRepository.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation
import CoreData

protocol TokenRepository {
    
    func getSavedRefreshToken() async throws -> String
    func saveRefreshToken(refreshToken: String)
    func deleteSavedToken()
    
    func refreshAccessToken(refreshToken: String) async throws -> AccessTokenResponse
}



final class TokenRepositoryImpl: TokenRepository {
    
    @Inject var httpRoute: HttpRoute
    @Inject var context: NSManagedObjectContext
    
    func getSavedRefreshToken() async throws -> String {
        let tokens = try context.fetch(RefreshToken.fetchRequest()) as! [RefreshToken]
        let response = tokens.isEmpty ? "" : tokens[0].value
        return response ?? ""
    }
    
    func saveRefreshToken(refreshToken: String) {
        do {
            let tokens = try context.fetch(RefreshToken.fetchRequest()) as! [RefreshToken]
            if tokens.isEmpty {
                let newSavedEntity = NSEntityDescription.entity(forEntityName: "RefreshToken", in: context)
                let newSavedToken = NSManagedObject(entity: newSavedEntity!, insertInto: context)
                newSavedToken.setValue(0, forKey: "id")
                newSavedToken.setValue(refreshToken, forKey: "value")
            } else {
                let savedToken = tokens[0]
                savedToken.setValue(0, forKey: "id")
                savedToken.setValue(refreshToken, forKey: "value")
            }
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteSavedToken() {
        let context = PersistenceController.shared.container.viewContext
        do {
            let tokens = try context.fetch(RefreshToken.fetchRequest()) as! [RefreshToken]
            tokens.forEach { refreshToken in
                context.delete(refreshToken)
            }
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func refreshAccessToken(refreshToken: String) async throws -> AccessTokenResponse {
        let urlSession = URLSession.shared
        var request = URLRequest.init(url: URL( string: httpRoute.refresh() )!)
        let requestData = ["refresh" : refreshToken]
        let requestJson = try! JSONSerialization.data(withJSONObject: requestData, options: [])
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = requestJson
        
        let (data, _) = try await urlSession.data(for: request)
        return try JSONDecoder().decode(AccessTokenResponse.self, from: data)
    }
}
