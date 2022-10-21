//
//  ShoppingBagView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI

struct ShoppingBagView: View {
    var body: some View {
        VStack {
            ScrollView{
                LazyVStack{
                    Divider()
                    Button {
                        // 삭제 로직
                    } label: {
                        HStack{
                            Image("category_icecream")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                            VStack{
                                Text("아이템 이름")
                                Text("( 브랜드 )")
                            }
                            Image(systemName: "paperplane")
                                .font(.body.weight(.bold))
                                .foregroundColor(.gray)
                            Text("요청됨")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                    Divider()
                    Button {
                        
                    } label: {
                        HStack{
                            Image("category_icecream")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                            VStack{
                                Text("아이템 이름")
                                Text("( 브랜드 )")
                            }
                            Image(systemName: "ellipsis.bubble")
                                .font(.body.weight(.bold))
                                .foregroundColor(.gray)
                            Text("처리중")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                    Divider()
                    Button {
                        
                    } label: {
                        HStack{
                            Image("category_icecream")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                            VStack{
                                Text("아이템 이름")
                                Text("( 브랜드 )")
                            }
                            Image(systemName: "checkmark.circle")
                                .font(.body.weight(.bold))
                                .foregroundColor(.green)
                            Text("지급 완료")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                    Divider()
                    Button {
                        
                    } label: {
                        HStack{
                            Image("category_icecream")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                            VStack{
                                Text("아이템 이름")
                                Text("( 브랜드 )")
                            }
                            Image(systemName: "x.circle")
                                .font(.body.weight(.bold))
                                .foregroundColor(.red)
                            Text("거절됨")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                    Divider()
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("구매 이력")
    }
}

struct ShoppingBagView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingBagView()
    }
}
