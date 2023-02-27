//
//  ShopView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI
import CachedAsyncImage

struct ShopView: View {
    
    @EnvironmentObject private var shopViewModel: ShopViewModel
    @EnvironmentObject private var coreState: CoreState
    
    @State private var isPurchaseDialogOpened = false
    @State private var selectedItem: Item? = nil
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationTitle(
                    title: "상점",
                    trailingIconSystemName: "list.bullet.rectangle.portrait",
                    onTrailingIconClick: {
                        coreState.navigate(Screen.ShoppingBag.route)
                    }
                )
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: .medium) {
                        RoundButton(
                            text: "전체보기",
                            foregroundColor: shopViewModel.selectedShopCategoty.isEmpty ? .white : .moreHeavyGray,
                            backgroundColor: shopViewModel.selectedShopCategoty.isEmpty ? .primary : .moreLightGray
                        ) {
                            shopViewModel.selectedShopCategoty = ""
                            shopViewModel.categorizeItems(selectedCategory: "")
                        }
                        .id("")
                        
                        ForEach(ItemCategory.categories, id: \.name){ itemCategory in
                            RoundButton(
                                iconSystemName: itemCategory.icon,
                                text: itemCategory.name,
                                foregroundColor: shopViewModel.selectedShopCategoty == itemCategory.name ? .white : .moreHeavyGray,
                                backgroundColor: shopViewModel.selectedShopCategoty == itemCategory.name ? .primary : .moreLightGray
                            ) {
                                shopViewModel.selectedShopCategoty = itemCategory.name
                                shopViewModel.categorizeItems(selectedCategory: itemCategory.name)
                            }
                            .id(itemCategory.name)
                        }
                    }
                    .padding(.horizontal, .moreLarge)
                    .padding(.vertical, .large)
                    .animation(.easeInOut(duration: .short), value: shopViewModel.selectedShopCategoty)
                }
                .scrollIndicators(.never)
                .frame(height: 52)
                
                Divider()
                
                if shopViewModel.itemLoading {
                    ProgressView()
                        .frame(height: 100)
                } else {
                    if shopViewModel.selectedCategoryItems.isEmpty {
                        EmptyImageView("아직 올라온 상품이 없어요")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(shopViewModel.selectedCategoryItems, id: \.id) { item in
                                    Button {
                                        selectedItem = item
                                        isPurchaseDialogOpened = true
                                    } label: {
                                        HStack(spacing: 16) {
                                            CachedAsyncImage(
                                                url: URL(string: item.image),
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
                                                Text(item.name)
                                                    .font(.body.bold())
                                                    .multilineTextAlignment(.leading)
                                                Text("( \(item.brand) )")
                                                    .foregroundColor(.heavyGray)
                                            }
                                            Spacer()
                                            HStack {
                                                Image(systemName: "p.circle")
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(.secondary)
                                                Text("\(item.price)")
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
            }
            .animation(.easeInOut, value: shopViewModel.selectedCategoryItems.isEmpty)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            Dialog(
                isDialogVisible: $isPurchaseDialogOpened,
                positiveButtonText: "구매하기",
                negativeButtonText: "취소",
                onPositivebuttonClick: {
                    guard let item = selectedItem else { return }
                    if coreState.user.point >= item.price {
                        Task {
                            await shopViewModel.requestPurchase(coreState: coreState, itemId: item.id)
                        }
                    } else {
                        coreState.showSnackBar(message: "포인트가 부족합니다", type: .info)
                    }
                },
                onNegativebuttonClick: { selectedItem = nil },
                onDismiss: { selectedItem = nil }
            ) {
                guard let item = selectedItem else { return Text("") }
                return Text("\(item.name)\n\n")
                    .foregroundColor(.primary)
                    .font(.subtitle.bold())
                +
                Text("필요 포인트: ")
                    .foregroundColor(.primary)
                +
                Text("\(item.price)P\n")
                    .foregroundColor(.primary)
                    .font(.body.bold())
                +
                Text("보유 포인트: ")
                    .foregroundColor(.primary)
                    .baselineOffset(-.small)
                +
                Text("\(coreState.user.point)P\n\n")
                    .foregroundColor(.primary)
                    .font(.body.bold())
                    .baselineOffset(-.small)
                +
                Text("구매하기 버튼을 클릭하면\n")
                    .foregroundColor(.heavyGray)
                +
                Text("포인트 확인후 기프티콘을 발송해드려요")
                    .foregroundColor(.heavyGray)
                    .baselineOffset(-.small)
            }
        }
        .task {
            await shopViewModel.getItems(coreState: coreState)
        }
    }
}

struct ItemCategory {
    let name, image, icon: String
}
extension ItemCategory {
    static let categories = [
        ItemCategory(name: "커피", image: "category_coffee", icon: "cup.and.saucer"),
        ItemCategory(name: "케이크", image: "category_cake", icon: "birthday.cake"),
        ItemCategory(name: "금액권", image: "category_giftcard", icon: "creditcard"),
        ItemCategory(name: "아이스크림", image: "category_icecream", icon: "snowflake"),
        ItemCategory(name: "디저트", image: "category_dessert", icon: "fork.knife"),
        ItemCategory(name: "논커피", image: "category_noncoffee", icon: "wineglass"),
    ]
}
