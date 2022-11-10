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
    
    let categoryItemButtonHeight = 44.0
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    ScrollViewReader{ proxy in
                        ScrollView(.horizontal){
                            LazyHStack{
                                RoundButton(
                                    buttonHeight: categoryItemButtonHeight,
                                    text: "전체보기",
                                    backgroundColor: shopViewModel.selectedShopCategoty.isEmpty ? Color.red : Color.gray
                                ) {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        shopViewModel.selectedShopCategoty = ""
                                    }
                                }
                                .id("")
                                
                                ForEach(ItemCategory.categories, id: \.name){ itemCategory in
                                    RoundButton(
                                        buttonHeight: categoryItemButtonHeight,
                                        iconSystemName: itemCategory.icon,
                                        text: itemCategory.name,
                                        backgroundColor: shopViewModel.selectedShopCategoty == itemCategory.name ? Color.red : Color.gray
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            shopViewModel.selectedShopCategoty = itemCategory.name
                                        }
                                    }
                                    .id(itemCategory.name)
                                }
                            }
                            .frame(height: categoryItemButtonHeight)
                            .padding(.horizontal, 20)
                        }
                        .scrollIndicators(.never)
                        .task {
                            proxy.scrollTo(shopViewModel.selectedShopCategoty)
                        }
                    }
                    
                    ScrollView{
                        LazyVStack{
                            if shopViewModel.itemLoading {
                                ProgressView()
                            } else {
                                ForEach(shopViewModel.items, id: \.id) { item in
                                    Button {
                                        if coreState.user.point >= item.price {
                                            Task {
                                                await shopViewModel.requestPurchase(coreState: coreState, itemId: item.id)
                                            }
                                        } else {
                                            coreState.showSnackBar(message: "포인트가 부족합니다", type: SnackBarType.error)
                                        }
                                    } label: {
                                        HStack{
                                            CachedAsyncImage(
                                                url: URL(string: item.image),
                                                content: { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 50)
                                                },
                                                placeholder: {
                                                    ProgressView()
                                                }
                                            )
                                            Spacer()
                                            VStack{
                                                Text(item.name)
                                                Text("( \(item.brand) )")
                                            }
                                            Spacer()
                                            Image(systemName: "cart")
                                                .font(.body.weight(.bold))
                                                .foregroundColor(.gray)
                                            Text("\(item.price) p")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 20)
                                    }
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                    .scrollIndicators(.hidden)
                }
                //
                //            CustomDialog(
                //                isDialogVisible: <#T##Binding<Bool>#>,
                //                content: <#T##String#>,
                //                positiveButtonText: <#T##String#>,
                //                negativeButtonText: <#T##String#>,
                //                onPositivebuttonClick: <#T##() -> Void#>,
                //                onNegativebuttonClick: <#T##() -> Void#>,
                //                onDismiss: <#T##() -> Void#>
                //            )
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("상점")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        coreState.navigate(Screen.ShoppingBag.route)
                    } label: {
                        Image(systemName: "cart")
                            .font(.body.weight(.bold))
                    }
                }
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
