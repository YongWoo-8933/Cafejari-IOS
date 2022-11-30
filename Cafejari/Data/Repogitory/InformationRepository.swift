//
//  InformationRepository.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation
import CoreData

protocol InformationRepository {
    
    func fetchIosVersion() async throws -> [Version]
    func getUpdateDisabledDate() async -> Date?
    func saveUpdateDisabledDate()
    func fetchEvents() async throws -> Events
    func fetchPointPolicies() async throws -> [PointPolicyResponse]
    func fetchCautions() async throws -> [CautionResponse]
    func fetchFAQs() async throws -> [FAQResponse]
    
    func postInquiryCafe(accessToken: String, email: String, cafeName: String, cafeAddress: String) async throws
    func postInquiryEtc(accessToken: String, email: String, content: String) async throws
}



final class InformationRepositoryImpl: InformationRepository {
    
    @Inject var httpRoute: HttpRoute
    @Inject var customUrlRequest: CustomURLRequest
    @Inject var context: NSManagedObjectContext
    
    func temp() {
        do {
            let dates = try context.fetch(UpdateDisabledDate.fetchRequest()) as! [UpdateDisabledDate]
            if dates.isEmpty {
                let newSavedEntity = NSEntityDescription.entity(forEntityName: "UpdateDisabledDate", in: context)
                let newSavedDate = NSManagedObject(entity: newSavedEntity!, insertInto: context)
                newSavedDate.setValue(0, forKey: "id")
                newSavedDate.setValue(Date.now - 86400, forKey: "date")
            } else {
                let savedDate = dates[0]
                savedDate.setValue(0, forKey: "id")
                savedDate.setValue(Date.now - 86400, forKey: "date")
            }
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchIosVersion() async throws -> [Version] {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.iosVersion())
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([Version].self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func getUpdateDisabledDate() async -> Date? {
        do {
            let dates = try context.fetch(UpdateDisabledDate.fetchRequest()) as! [UpdateDisabledDate]
            return dates.isEmpty ? nil : dates[0].date
        } catch {
            print(error)
            return nil
        }
    }
    
    func saveUpdateDisabledDate() {
        do {
            let dates = try context.fetch(UpdateDisabledDate.fetchRequest()) as! [UpdateDisabledDate]
            if dates.isEmpty {
                let newSavedEntity = NSEntityDescription.entity(forEntityName: "UpdateDisabledDate", in: context)
                let newSavedDate = NSManagedObject(entity: newSavedEntity!, insertInto: context)
                newSavedDate.setValue(0, forKey: "id")
                newSavedDate.setValue(Date.now, forKey: "date")
            } else {
                let savedDate = dates[0]
                savedDate.setValue(0, forKey: "id")
                savedDate.setValue(Date.now, forKey: "date")
            }
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchEvents() async throws -> Events {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.event())
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(Events.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func fetchPointPolicies() async throws -> [PointPolicyResponse] {
        do{
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.pointPolicy())
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([PointPolicyResponse].self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func fetchCautions() async throws -> [CautionResponse] {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.caution())
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([CautionResponse].self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func fetchFAQs() async throws -> [FAQResponse] {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.faq())
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([FAQResponse].self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    
    func postInquiryCafe(accessToken: String, email: String, cafeName: String, cafeAddress: String) async throws {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.inquiryCafe(),
                accessToken: accessToken,
                requestBody: ["email": email, "cafe_name": cafeName, "cafe_address": cafeAddress]
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
    
    func postInquiryEtc(accessToken: String, email: String, content: String) async throws {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.inquiryEtc(),
                accessToken: accessToken,
                requestBody: ["email": email, "content": content]
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
