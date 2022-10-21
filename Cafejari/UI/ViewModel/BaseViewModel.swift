//
//  BaseViewModel.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation
import SwiftUI


class BaseViewModel: ObservableObject {
    
    @Inject var tokenRepository: TokenRepository
    
    func getSavedRefreshToken() async throws -> String {
        return try await tokenRepository.getSavedRefreshToken()
    }
    
    func saveRefreshToken(refreshToken: String) {
        tokenRepository.saveRefreshToken(refreshToken: refreshToken)
    }
    
    func deleteSavedRefreshToken() {
        tokenRepository.deleteSavedToken()
    }
    
    func refreshAccessToken(refreshToken: String) async throws -> String {
        do{
            let accessTokenResponse = try await tokenRepository.refreshAccessToken(refreshToken: refreshToken)
            return accessTokenResponse.access
            
        }catch {
            print(error.localizedDescription)
            throw(fatalError())
        }
    }
}
