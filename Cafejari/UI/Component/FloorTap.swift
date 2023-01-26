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
            ForEach(cafeViewModel.modalCafeInfo.cafes, id: \.id) { cafe in
                VStack(spacing: .small) {
                    Text("\(cafe.floor.toFloor())층")
                        .foregroundColor(cafeViewModel.modalCafe.id == cafe.id ? .primary :
                             useDisabledFloorButton && !cafe.isMasterAvailable() ? .lightGray : .heavyGray)
                        .font(.body.bold())
                        .frame(width: 58, height: 30)
                        .background( cafeViewModel.modalCafe.id == cafe.id ? .white :
                            useDisabledFloorButton && !cafe.isMasterAvailable() ? .heavyGray : .moreLightGray )
                        .cornerRadius(cafeViewModel.modalCafe.id == cafe.id ? .zero : 6)
                        .roundBorder(
                            cornerRadius: 6, lineWidth: 2, borderColor: cafeViewModel.modalCafe.id == cafe.id ? .primary : .clear)
                        .onTapGesture {
                            if !useDisabledFloorButton || cafe.isMasterAvailable() {
                                withAnimation(.spring()) {
                                    cafeViewModel.modalCafe = cafe
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



