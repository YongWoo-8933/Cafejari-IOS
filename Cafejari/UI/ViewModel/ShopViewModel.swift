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
    @Published var selectedShopCategoty = ""
    @Published var purchases: Purchases = []
    
    @Inject var shopRepository: ShopRepository
    
    func getItems(coreState: CoreState) async {
        itemLoading = true
        do {
            items = try await shopRepository.fetchItems()
            itemLoading = false
        } catch CustomError.errorMessage(let msg) {
            itemLoading = false
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            itemLoading = false
            print(error)
        }
    }
    
    func requestPurchase(coreState: CoreState, itemId: Int) async {
        do {
            _ = try await shopRepository.postPurchaseRequest(accessToken: coreState.accessToken, itemId: itemId)
            self.purchases = try await shopRepository.fetchPurchaseRequests(accessToken: coreState.accessToken)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                coreState.navigate(Screen.ShoppingBag.route)
                coreState.showSnackBar(message: "구매 요청 완료")
            }
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await requestPurchase(coreState: coreState, itemId: itemId)
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
    
    func getPurchases(coreState: CoreState) async {
        do {
            self.purchases = try await shopRepository.fetchPurchaseRequests(accessToken: coreState.accessToken)
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await getPurchases(coreState: coreState)
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
    
    func deletePurchase(coreState: CoreState, purchaseId: Int) async {
        do {
            try await shopRepository.deletePurchaseRequest(accessToken: coreState.accessToken, purchaseId: purchaseId)
            self.purchases = try await shopRepository.fetchPurchaseRequests(accessToken: coreState.accessToken)
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await deletePurchase(coreState: coreState, purchaseId: purchaseId)
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
}
