//
//  ShopRepository.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/17.
//

import Foundation

protocol ShopRepository {
    
    func fetchItems() async throws -> Items
    func fetchPurchaseRequests(accessToken: String) async throws -> Purchases
    func postPurchaseRequest(accessToken: String, itemId: Int) async throws -> Purchase
    func deletePurchaseRequest(accessToken: String, purchaseId: Int) async throws
}



final class ShopRepositoryImpl: ShopRepository {
    
    @Inject var httpRoute: HttpRoute
    @Inject var customUrlRequest: CustomURLRequest
    
    func fetchItems() async throws -> Items {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.item())
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(Items.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func fetchPurchaseRequests(accessToken: String) async throws -> Purchases {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.purchaseRequest(), accessToken: accessToken)
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(Purchases.self, from: data)
                
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
    
    func postPurchaseRequest(accessToken: String, itemId: Int) async throws -> Purchase {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.purchaseRequest(),
                accessToken: accessToken,
                requestBody: ["item_id": itemId]
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(Purchase.self, from: data)
                
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
    
    func deletePurchaseRequest(accessToken: String, purchaseId: Int) async throws {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.delete(
                urlString: httpRoute.deletePurchaseRequest(id: purchaseId),
                accessToken: accessToken
            )
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
}
