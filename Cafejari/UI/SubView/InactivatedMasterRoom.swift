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
    
    @State private var isTouchTextVisible = false
    @State private var isCrowdedPartTouched = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                // 층 선택
                Text("마스터 할 층을 선택해주세요")
                    .font(.headline.weight(.medium))
                
                VerticalSpacer(.large)
                
                FloorTap(useDisabledFloorButton: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VerticalSpacer(40)
            }
            
            Group {
                // 혼잡도 선택
                Text("선택한 층의 혼잡도를 선택해주세요")
                    .font(.headline.weight(.medium))
                
                VerticalSpacer(.large)
                
                VStack(spacing: .medium) {
                    Text(selectedCrowded.toCrowded().detailString)
                        .foregroundColor(.primary)
                    
                    VerticalSpacer(.small)
                    
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            ForEach(Crowded.crowdedListExceptNegative, id: \.value) { crowded in
                                VStack {
                                    if selectedCrowded == crowded.value {
                                        Image(crowded.image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24)
                                    } else {
                                        Color.white
                                    }
                                }
                                .frame(width: geo.size.width / 5)
                                .onTapGesture {
                                    selectedCrowded = crowded.value
                                }
                            }
                        }
                        .frame(width: geo.size.width, height: 30)
                        HStack(spacing: 0) {
                            Text("터치해서 혼잡도를 변경해보세요!")
                                .font(.body2)
                                .foregroundColor(.white)
                        }
                        .frame(width: geo.size.width, height: 34)
                        .background(Color.black.opacity(0.4))
                        .opacity(!isCrowdedPartTouched && isTouchTextVisible ? 1 : 0)
                        .cornerRadius(.medium)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: .long)) {
                                isCrowdedPartTouched = true
                            }
                        }
                    }
                    .frame(height: 34)
                    
                    CrowdedColorBar()
                }
                .padding(.horizontal, .large)
                .padding(.vertical, 28)
                .roundBorder(cornerRadius: .moreLarge, lineWidth: 1.5, borderColor: .primary)
                .animation(.easeInOut(duration: .short), value: selectedCrowded)
                .task {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                        isTouchTextVisible.toggle()
                    }
                }
            }
        }
        .padding(.moreLarge)
        .padding(.vertical, .moreLarge)
        
        SecondaryDivider()
        
        VStack(alignment: .leading, spacing: 0) {
            Group {
                // 현재 위치 확인
                Text("현재 위치를 확인하고 마스터 등록을 완료해주세요")
                    .font(.headline.bold())
                
                VerticalSpacer(.medium)
                
                Text("*현위치와 카페위치가 같아야 마스터 등록을 할 수 있어요.")
                    .font(.caption)
                    .foregroundColor(.heavyGray)
                
                VerticalSpacer(.large)
                
                MiniGoogleMapView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .cornerRadius(.medium)
                
                VerticalSpacer(.large)
                
                HStack(spacing: .large) {
                    RoundButton(
                        iconSystemName: "location",
                        text: "위치 조정하기",
                        foregroundColor: .white,
                        backgroundColor: .secondary
                    ) {
                        coreState.startLocationTracking()
                    }
                    Text(coreState.isNearBy(latitude: coreState.masterRoomCafeLog.latitude, longitude: coreState.masterRoomCafeLog.longitude) ? "현위치와 카페위치가 동일해요!" : "현위치가 카페와 너무 멀어요!")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                VerticalSpacer(30)
            }
            
            
            FilledCtaButton(text: "마스터 등록 완료!", backgroundColor: .primary, isProgress: cafeViewModel.isMasterRoomCtaProgress) {
                if coreState.isNearBy(latitude: coreState.masterRoomCafeLog.latitude, longitude: coreState.masterRoomCafeLog.longitude) {
                    Task {
                        await cafeViewModel.registerMaster(coreState: coreState, crowded: selectedCrowded)
                    }
                } else {
                    coreState.showSnackBar(message: "현재 위치가 카페와 너무 멀어요. 위치 조정후 다시 시도해주세요!", type: SnackBarType.error)
                }
            }
        }
        .padding(.moreLarge)
        .padding(.vertical, .moreLarge)
    }
}
