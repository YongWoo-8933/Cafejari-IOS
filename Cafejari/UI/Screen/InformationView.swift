//
//  InformationView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI

struct InformationView: View {
    
    @State private var selectedInfoTabBarIndex = 0
    
    var body: some View {
        VStack{
            HStack{
                Button{
                    selectedInfoTabBarIndex = 0
                }label: {
                    Text("포인트 정책")
                        .foregroundColor(selectedInfoTabBarIndex == 0 ? .black : .gray)
                }
                Spacer()
                Button{
                    selectedInfoTabBarIndex = 1
                }label: {
                    Text("주의사항")
                        .foregroundColor(selectedInfoTabBarIndex == 1 ? .black : .gray)
                }
                Spacer()
                Button{
                    selectedInfoTabBarIndex = 2
                }label: {
                    Text("FAQ")
                        .foregroundColor(selectedInfoTabBarIndex == 2 ? .black : .gray)
                }
                Spacer()
                Button{
                    selectedInfoTabBarIndex = 3
                }label: {
                    Text("문의/건의")
                        .foregroundColor(selectedInfoTabBarIndex == 3 ? .black : .gray)
                }
            }
            
            TabView(selection: $selectedInfoTabBarIndex){
                Text("포인트 정책")
                    .tag(0)
                Text("주의사항")
                    .tag(1)
                Text("FAQ")
                    .tag(2)
                Text("문의/건의")
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("안내")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView()
    }
}
