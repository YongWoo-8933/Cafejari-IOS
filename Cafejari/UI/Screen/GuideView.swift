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
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                TabView(selection: $currentPageIndex) {
                    ForEach(0 ..< guideImages.count, id: \.self){ index in
                        Image(guideImages[index])
                            .resizable()
                            .scaledToFit()
                            .tag(index)
                    }
                }
                .frame(maxHeight: .infinity)
                .tabViewStyle(.page)
                .accentColor(.black)
                .navigationBarBackButtonHidden()
                
                Spacer()
                
                HStack {
                    ForEach(0 ..< guideImages.count, id: \.self){ index in
                        if(index == currentPageIndex){
                            Image("stamp_icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                        } else {
                            Image(systemName: "circle")
                                .font(.callout.weight(.bold))
                        }
                    }
                }
            }
            Button {
                dismiss()
            } label: {
                Image(systemName: "x.circle.fill")
                    .font(.system(size: 36, weight: .bold))
                    .background(Color.white)
                    .frame(width: 36, height: 36)
                    .cornerRadius(18)
            }
            .padding(.moreLarge)
        }
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.white.opacity(0.0001))
            UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.white.opacity(0.0001))
        }
    }
}
