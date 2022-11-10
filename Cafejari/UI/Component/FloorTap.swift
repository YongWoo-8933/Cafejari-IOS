//
//  FloorTapShape.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/16.
//

import SwiftUI

struct FloorTap: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    
    var body: some View {
        HStack {
            ForEach(Array(cafeViewModel.modalCafeInfo.cafes.enumerated()), id: \.offset) { index, cafe in
                Text("\(cafe.floor.toFloor())층")
                    .foregroundColor(.black)
                    .font(.body)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(cafeViewModel.modalCafeIndex == index ? Color.white : Color.gray)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(cafeViewModel.modalCafeIndex == index ? Color.black : Color.gray, lineWidth: 1.5)
                    )
                    .onTapGesture {
                        withAnimation(.spring()) {
                            cafeViewModel.modalCafeIndex = index
                        }
                    }
            }
        }
    }
}



