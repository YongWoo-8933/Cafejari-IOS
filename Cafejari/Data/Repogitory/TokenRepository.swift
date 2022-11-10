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
    @Inject var customUrlRequest: CustomURLRequest
    
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
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(urlString: httpRoute.refresh(), requestBody: ["refresh" : refreshToken])
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.refreshTokenExpired
            } else if (200..<300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(AccessTokenResponse.self, from: data)
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.refreshTokenExpired {
            throw CustomError.refreshTokenExpired
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
}
