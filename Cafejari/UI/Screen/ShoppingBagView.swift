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
    
    @State private var selectedPurchase: Purchase? = nil
    @State private var isPurchaseHistoryDeleteDialogOpened = false
    
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
                self.color = .crowdedRed
            case 1:
                self.string = "처리중"
                self.image = "ellipsis.bubble"
                self.color = .gray
            case 2:
                self.string = "지급완료"
                self.image = "checkmark.circle"
                self.color = .crowdedGreen
            default:
                self.string = "요청됨"
                self.image = "paperplane"
                self.color = .gray
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationTitle(title: "구매 이력", leadingIconSystemName: "chevron.backward") {
                    coreState.popUp()
                }
                Divider()
                
                if shopViewModel.purchases.isEmpty {
                    VStack {
                        Image("empty")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .offset(x: 0, y: -.moreLarge)
                        Text("상품을 구매한 이력이 없어요")
                            .foregroundColor(.primary)
                            .font(.title.bold())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(shopViewModel.purchases, id: \.id) { purchase in
                                let purchaseType = PuchaseType(purchase.state)
                                Button {
                                    if purchaseType.int != 1 {
                                        selectedPurchase = purchase
                                        isPurchaseHistoryDeleteDialogOpened = true
                                    } else {
                                        coreState.showSnackBar(message: "처리 진행중인 요청은 삭제할 수 없습니다", type: .info)
                                    }
                                } label: {
                                    HStack(spacing: 16) {
                                        CachedAsyncImage(
                                            url: URL(string: purchase.item.image)!,
                                            content: { image in
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 60)
                                            },
                                            placeholder: {
                                                ProgressView()
                                            }
                                        )
                                        VStack(alignment: .leading, spacing: .medium) {
                                            Text(purchase.item.name)
                                                .font(.body.bold())
                                            Text("( \(purchase.item.brand) )")
                                                .foregroundColor(.heavyGray)
                                        }
                                        Spacer()
                                        HStack {
                                            Image(systemName: purchaseType.image)
                                                .font(.subheadline.bold())
                                                .foregroundColor(purchaseType.color)
                                            Text(purchaseType.string)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.moreLarge)
                                }
                                Divider()
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarBackButtonHidden()
            .task {
                await shopViewModel.getPurchases(coreState: coreState)
            }
            
            Dialog(
                isDialogVisible: $isPurchaseHistoryDeleteDialogOpened,
                positiveButtonText: "삭제",
                negativeButtonText: "취소",
                onPositivebuttonClick: {
                    Task {
                        if let purchase = selectedPurchase {
                            await shopViewModel.deletePurchase(coreState: coreState, purchaseId: purchase.id)
                        }
                    }
                },
                onNegativebuttonClick: { selectedPurchase = nil },
                onDismiss: { selectedPurchase = nil }
            ) {
                guard let purchase = selectedPurchase else { return Text("") }
                return Text(purchase.state == 0 ? "해당 상품 구매요청이 취소됩니다." : "해당 구매 이력이 삭제됩니다.") + Text("\n삭제하시겠습니까?").bold().baselineOffset(-.medium)
            }
        }
    }
}
