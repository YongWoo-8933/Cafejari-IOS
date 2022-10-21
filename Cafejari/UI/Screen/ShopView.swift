//
//  ShopView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI
import CachedAsyncImage

struct ShopView: View {
    @State var selectedCategoryId: UUID?
    @EnvironmentObject private var shopViewModel: ShopViewModel
    
    let categoryItemButtonHeight = 50.0
    
    var body: some View {
        VStack {
            ScrollViewReader{ proxy in
                ScrollView(.horizontal){
                    LazyHStack{
                        Button {
                            selectedCategoryId = nil
                        } label: {
                            Text("전체보기")
                        }
                        .padding(.horizontal, 15)
                        .frame(height: categoryItemButtonHeight)
                        .background{
                            if(selectedCategoryId == nil){
                                Color.red
                            } else {
                                Color.gray
                            }
                        }
                        .cornerRadius(categoryItemButtonHeight / 2)
                        
                        ForEach(ItemCategory.itemCategories){ itemCategory in
                            Button {
                                selectedCategoryId = itemCategory.id
                            } label: {
                                HStack{
                                    Image(systemName: itemCategory.icon)
                                        .font(.callout.weight(.bold))
                                        .frame(width: 15, height: 15)
                                    Text(itemCategory.name)
                                }
                            }
                            .padding(.horizontal, 15)
                            .frame(height: categoryItemButtonHeight)
                            .background{
                                if(selectedCategoryId == itemCategory.id){
                                    Color.red
                                } else {
                                    Color.gray
                                }
                            }
                            .cornerRadius(categoryItemButtonHeight / 2)
                        }
                    }
                    .frame(height: categoryItemButtonHeight)
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
            }
            ScrollView{
                LazyVStack{
                    if shopViewModel.itemLoading {
                        ProgressView()
                    } else {
                        ForEach(shopViewModel.items, id: \.id) { item in
                            Button {
                                
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ShoppingBagView()
                } label: {
                    Image(systemName: "cart")
                        .font(.body.weight(.bold))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("상점")
        .task {
            await shopViewModel.getItems()
        }
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView()
            .accentColor(.black)
    }
}
