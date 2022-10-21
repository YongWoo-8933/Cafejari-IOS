//
//  ShopRepository.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/17.
//

import Foundation

protocol ShopRepository {
    
    func fetchItems() async throws -> Items
}



final class ShopRepositoryImpl: ShopRepository {
    
    @Inject var httpRoute: HttpRoute
    
    func fetchItems() async throws -> Items {
        let urlSession = URLSession.shared
        let url = URL( string: httpRoute.item() )
        let (data, _) = try await urlSession.data(from: url!)
        return try JSONDecoder().decode(Items.self, from: data)
    }
}
