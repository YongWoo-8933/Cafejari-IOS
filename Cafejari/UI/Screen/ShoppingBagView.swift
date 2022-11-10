//
//  ShoppingBagView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI
import CachedAsyncImage

struct ShoppingBagView: View {
    
    @EnvironmentObject private var shopViewModel: ShopViewModel
    @EnvironmentObject private var coreState: CoreState
    
    struct PuchaseType {
        let int: Int
        let string: String
        let image: String
        let color: Color
        
        init(_ int: Int) {
            self.int = int
            switch(int) {
            case -1:
                self.string = "거절됨"
                self.image = "x.circle"
                self.color = Color.red
            case 1:
                self.string = "처리중"
                self.image = "ellipsis.bubble"
                self.color = Color.gray
            case 2:
                self.string = "지급완료"
                self.image = "checkmark.circle"
                self.color = Color.green
            default:
                self.string = "요청됨"
                self.image = "paperplane"
                self.color = Color.gray
            }
        }
    }
    
    var body: some View {
        VStack {
            ScrollView{
                LazyVStack{
                    ForEach(shopViewModel.purchases, id: \.id) { purchase in
                        Divider()
                        let purchaseType = PuchaseType(purchase.state)
                        Button {
                            if purchaseType.int != 1 {
                                Task {
                                    await shopViewModel.deletePurchase(coreState: coreState, purchaseId: purchase.id)
                                }
                            }
                        } label: {
                            HStack{
                                CachedAsyncImage(url: URL(string: purchase.item.image)!) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50)
                                } placeholder: {
                                    ProgressView()
                                }
                                VStack{
                                    Text(purchase.item.name)
                                    Text("( \(purchase.item.brand) )")
                                }
                                Image(systemName: purchaseType.image)
                                    .font(.body.weight(.bold))
                                    .foregroundColor(purchaseType.color)
                                Text(purchaseType.string)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        }
                    }
                    Divider()
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("장바구니")
        .task {
            await shopViewModel.getPurchases(coreState: coreState)
        }
    }
}
