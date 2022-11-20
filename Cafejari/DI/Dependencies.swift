//
//  Dependencies.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation
import CoreData
import CoreLocation
import SwiftUI

class Dependencies {
    
    init() {
        @Provider var httpRoute = HttpRoute()
        @Provider var customUrlRequest = CustomURLRequest()
        @Provider var context = PersistenceController.shared.container.viewContext as NSManagedObjectContext
        
        @Provider var time = Time()
        @Provider var tokenRepository = TokenRepositoryImpl() as TokenRepository
        @Provider var loginRepository = LoginRepositoryImpl() as LoginRepository
        @Provider var userRepository = UserRepositoryImpl() as UserRepository
        @Provider var cafeRepository = CafeRepositoryImpl() as CafeRepository
        @Provider var shopRepository = ShopRepositoryImpl() as ShopRepository
        @Provider var informationRepository = InformationRepositoryImpl() as InformationRepository
    }
}
