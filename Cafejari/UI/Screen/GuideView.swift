//
//  GuideView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI

struct GuideView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPageIndex = 0
    let guideImages: [String]
    
    var body: some View {
        ZStack{
            TabView(selection: $currentPageIndex) {
                ForEach(0 ..< guideImages.count, id: \.self){ index in
                    Image(guideImages[index])
                        .resizable()
                        .scaledToFit()
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .accentColor(.black)
            .navigationBarBackButtonHidden()
            VStack{
                HStack{
                    Spacer()
                    Button{
                        dismiss()
                    }label: {
                        Image(systemName: "x.circle.fill")
                            .font(.title.weight(.bold))
                    }
                }
                Spacer()
                HStack {
                    ForEach(0 ..< guideImages.count, id: \.self){ index in
                        if(index == currentPageIndex){
                            Image("stamp_icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                        }else{
                            Image(systemName: "circle")
                                .font(.callout.weight(.bold))
                        }
                    }
                }
            }
            .padding()
        }
    }
}
