//
//  Dependencies.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation
import CoreData

class Dependencies {
    
    init(){
        @Provider var httpRoute = HttpRoute()
        @Provider var context = PersistenceController.shared.container.viewContext as NSManagedObjectContext
        
        @Provider var tokenRepository = TokenRepositoryImpl() as TokenRepository
        @Provider var userRepository = UserRepositoryImpl() as UserRepository
        @Provider var cafeRepository = CafeRepositoryImpl() as CafeRepository
        @Provider var shopRepository = ShopRepositoryImpl() as ShopRepository
        @Provider var informationRepository = InformationRepositoryImpl() as InformationRepository
    }
}
