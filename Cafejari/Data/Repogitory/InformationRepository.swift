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
    func getPopUpDisabledDate() async -> Date?
    func saveUpdateDisabledDate()
    func savePopUpDisabledDate()
    func fetchEvents() async throws -> Events
    func fetchEventPointHistories(accessToken: String) async throws -> EventPointHistories
    func fetchFAQs() async throws -> [FAQResponse]
    func fetchPopUpNotifications() async throws -> [PopUpNotificationResponse]
    func fetchOnSaleCafes() async throws -> [OnSaleCafeResponse]
    
    func fetchInquiryCafes(accessToken: String) async throws -> [InquiryCafeResponse]
    func fetchInquiryEtcs(accessToken: String) async throws -> [InquiryEtcResponse]
    func postInquiryCafe(accessToken: String, email: String, cafeName: String, cafeAddress: String) async throws
    func postInquiryEtc(accessToken: String, email: String, content: String) async throws
    func postInquiryCafeAdditionalInfo(
        accessToken: String,
        cafeInfoIndex: Int,
        storeInfo: String,
        openingHour: String,
        wallSocket: String,
        restroom: String
    ) async throws
    func deleteInquiryCafe(accessToken: String, inquiryCafeId: Int) async throws
    func deleteInquiryEtc(accessToken: String, inquiryEtcId: Int) async throws
}



final class InformationRepositoryImpl: InformationRepository {
    
    @Inject var httpRoute: HttpRoute
    @Inject var customUrlRequest: CustomURLRequest
    @Inject var context: NSManagedObjectContext
    
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
            return dates.first { res in
                res.id == DisabledDateId.update
            }?.date
        } catch {
            print(error)
            return nil
        }
    }
    
    func getPopUpDisabledDate() async -> Date? {
        do {
            let dates = try context.fetch(UpdateDisabledDate.fetchRequest()) as! [UpdateDisabledDate]
            return dates.first { res in
                res.id == DisabledDateId.popUp
            }?.date
        } catch {
            print(error)
            return nil
        }
    }
    
    func saveUpdateDisabledDate() {
        do {
            let dates = try context.fetch(UpdateDisabledDate.fetchRequest()) as! [UpdateDisabledDate]
            let savedUpdateDisabledDate = dates.first { res in
                res.id == DisabledDateId.update
            }
            if let savedUpdateDisabledDate = savedUpdateDisabledDate {
                savedUpdateDisabledDate.setValue(DisabledDateId.update, forKey: "id")
                savedUpdateDisabledDate.setValue(Date.now, forKey: "date")
            } else {
                let newUpdateDisabledDateEntity = NSEntityDescription.entity(forEntityName: "UpdateDisabledDate", in: context)
                let newUpdateDisabledDate = NSManagedObject(entity: newUpdateDisabledDateEntity!, insertInto: context)
                newUpdateDisabledDate.setValue(DisabledDateId.update, forKey: "id")
                newUpdateDisabledDate.setValue(Date.now, forKey: "date")
            }
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func savePopUpDisabledDate() {
        do {
            let dates = try context.fetch(UpdateDisabledDate.fetchRequest()) as! [UpdateDisabledDate]
            let savedPopUpDisabledDate = dates.first { res in
                res.id == DisabledDateId.popUp
            }
            if let savedPopUpDisabledDate = savedPopUpDisabledDate {
                savedPopUpDisabledDate.setValue(DisabledDateId.popUp, forKey: "id")
                savedPopUpDisabledDate.setValue(Date.now, forKey: "date")
            } else {
                let newPopDisabledDateEntity = NSEntityDescription.entity(forEntityName: "UpdateDisabledDate", in: context)
                let newPopDisabledDate = NSManagedObject(entity: newPopDisabledDateEntity!, insertInto: context)
                newPopDisabledDate.setValue(DisabledDateId.popUp, forKey: "id")
                newPopDisabledDate.setValue(Date.now, forKey: "date")
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
    
    func fetchEventPointHistories(accessToken: String) async throws -> EventPointHistories {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.event_point_history(), accessToken: accessToken)
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if (200..<300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(EventPointHistories.self, from: data)
                
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
    
    func fetchInquiryCafes(accessToken: String) async throws -> [InquiryCafeResponse] {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.inquiryCafe(), accessToken: accessToken)
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if (200..<300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([InquiryCafeResponse].self, from: data)
                
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
    
    func fetchInquiryEtcs(accessToken: String) async throws -> [InquiryEtcResponse] {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.inquiryEtc(), accessToken: accessToken)
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if (200..<300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([InquiryEtcResponse].self, from: data)
                
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
    
    func deleteInquiryCafe(accessToken: String, inquiryCafeId: Int) async throws {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.delete (
                urlString: httpRoute.deleteInquiryCafe(id: inquiryCafeId),
                accessToken: accessToken
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                // success
                
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
    
    func deleteInquiryEtc(accessToken: String, inquiryEtcId: Int) async throws {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.delete (
                urlString: httpRoute.deleteInquiryEtc(id: inquiryEtcId),
                accessToken: accessToken
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                // success
                
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
    
    func postInquiryCafeAdditionalInfo(
        accessToken: String,
        cafeInfoIndex: Int,
        storeInfo: String,
        openingHour: String,
        wallSocket: String,
        restroom: String
    ) async throws {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.inquiryCafeAdditionalInfo(),
                accessToken: accessToken,
                requestBody: [
                    "cafe_info": cafeInfoIndex,
                    "store_information": storeInfo,
                    "opening_hour": openingHour,
                    "wall_socket": wallSocket,
                    "restroom": restroom
                ]
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
    
    func fetchPopUpNotifications() async throws -> [PopUpNotificationResponse] {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.popUpNotification())
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([PopUpNotificationResponse].self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func fetchOnSaleCafes() async throws -> [OnSaleCafeResponse] {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.onSaleCafe())
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode([OnSaleCafeResponse].self, from: data)
                
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
