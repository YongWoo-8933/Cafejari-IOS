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
    
    let useDisabledFloorButton: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            ForEach(Array(cafeViewModel.modalCafeInfo.cafes.enumerated()), id: \.offset) { index, cafe in
                VStack(spacing: .small) {
                    Text("\(cafe.floor.toFloor())층")
                        .foregroundColor(cafeViewModel.modalCafeIndex == index ? .primary :
                             useDisabledFloorButton && !cafe.isMasterAvailable() ? .lightGray : .heavyGray)
                        .font(.body.bold())
                        .frame(width: 58, height: 30)
                        .background( cafeViewModel.modalCafeIndex == index ? .white :
                            useDisabledFloorButton && !cafe.isMasterAvailable() ? .heavyGray : .moreLightGray )
                        .cornerRadius(cafeViewModel.modalCafeIndex == index ? .zero : .small)
                        .roundBorder(
                            cornerRadius: .small, lineWidth: 2, borderColor: cafeViewModel.modalCafeIndex == index ? .primary : .clear)
                        .onTapGesture {
                            if !useDisabledFloorButton || cafe.isMasterAvailable() {
                                withAnimation(.spring()) {
                                    cafeViewModel.modalCafeIndex = index
                                }
                            }
                        }
                    if useDisabledFloorButton && !cafe.isMasterAvailable() {
                        Text("(활동중)")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
            }
        }
        .frame(height: useDisabledFloorButton ? 50 : 32)
    }
}



