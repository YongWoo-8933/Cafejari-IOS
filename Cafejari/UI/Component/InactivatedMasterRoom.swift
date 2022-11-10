//
//  InactivatedMasterRoom.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/06.
//

import SwiftUI

struct InactivatedMasterRoom: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    
    @Binding var selectedCrowded: Int
    
    var body: some View {
        Group {
            VerticalSpacer(10)
            Text("마스터 할 층을 선택해주세요")
                .font(.headline)
            
            VerticalSpacer(10)
            HStack {
                ForEach(Array(cafeViewModel.modalCafeInfo.cafes.enumerated()), id: \.offset) { index, cafe in
                    VStack(spacing: 5) {
                        Text("\(cafe.floor.toFloor())층")
                            .font(.body)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(cafeViewModel.modalCafeIndex == index ? Color.white : Color.gray)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(cafeViewModel.modalCafeIndex == index ? Color.black : Color.gray, lineWidth: 1.5)
                            )
                            .onTapGesture {
                                if cafe.isMasterAvailable() {
                                    withAnimation(.spring()) {
                                        cafeViewModel.modalCafeIndex = index
                                    }
                                }
                            }
                            .opacity(cafe.isMasterAvailable() ? 1 : 0.2)
                        if !cafe.isMasterAvailable() {
                            Text("(활동중)")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    .frame(height: 60, alignment: .top)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VerticalSpacer(40)
        }
        
        Group {
            Text("선택한 층의 혼잡도를 선택해주세요")
                .font(.headline)
            
            VerticalSpacer(10)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(Crowded.crowdedListExceptNegative, id: \.value) { crowded in
                        Button {
                            selectedCrowded = crowded.value
                        } label: {
                            if selectedCrowded == crowded.value {
                                VStack {
                                    Text(crowded.string)
                                        .font(.headline)
                                    
                                    Image(crowded.image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24)
                                }
                                .frame(width: 60, height: 80)
                            } else {
                                VStack {
                                    Color.gray
                                }
                                .frame(width: 60, height: 80)
                            }
                        }
                    }
                }
                .frame(width: 300)
                
                HStack(spacing: 0){
                    ForEach(Crowded.crowdedListExceptNegative, id: \.value) { crowded in
                        HStack{
                            
                        }
                        .frame(width: 60, height: 6)
                        .background(crowded.color)
                    }
                }
                .frame(width: 300, height: 6)
                .cornerRadius(3)
                .padding(.vertical, 5)
                
                HStack(spacing: 0) {
                    ForEach(Crowded.crowdedListExceptNegative, id: \.value) { crowded in
                        Text(crowded.string)
                            .frame(width: 60)
                    }
                }
                .frame(width: 300)
            }
            .frame(maxWidth: .infinity)
            .padding(15)
            .background(.gray)
            .cornerRadius(20)
            
            VerticalSpacer(40)
        }
        
        Group {
            HStack {
                Text("지도")
                    .frame(height: 200)
            }
            .frame(maxWidth: .infinity)
            .background(.gray)
            VerticalSpacer(10)
            
            Text("현재 위치를 확인하고 마스터 등록을 완료해주세요")
                .font(.headline)
            VerticalSpacer(10)
            
            Text("*현재 위치가 카페 위치와 다르면 마스터등록을 할 수 없어요!")
                .font(.caption)
                .foregroundColor(.gray)
            VerticalSpacer(10)
            
            HStack {
                Button {
                    
                } label: {
                    Circle()
                        .fill(.white)
                        .frame(width: 18)
                    Text("위치 조정하기")
                        .font(.footnote)
                }
                .padding(6)
                .background(.gray)
                .cornerRadius(15)
                
                Text("현위치와 카페 위치가 동일해요!")
                    .font(.headline)
            }
        }
        
        VerticalSpacer(40)
        Button {
            Task {
                await cafeViewModel.registerMaster(coreState: coreState, crowded: selectedCrowded)
            }
        } label: {
            HStack {
                Text("마스터 등록")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.black)
        }
    }
}
