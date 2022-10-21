//
//  ShopViewModel.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation

@MainActor
final class ShopViewModel: BaseViewModel {
    
    @Published var items: Items = []
    @Published var itemLoading = false
    
    @Inject var shopRepository: ShopRepository
    
    func getItems() async {
        itemLoading = true
        do {
            items = try await shopRepository.fetchItems()
            itemLoading = false
        } catch {
            print(error)
            itemLoading = false
        }
    }
}
