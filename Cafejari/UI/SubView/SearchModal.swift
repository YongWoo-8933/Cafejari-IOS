//
//  SearchModal.swift
//  Cafejari
//
//  Created by 안용우 on 2023/02/25.
//

import SwiftUI
import NMapsMap

struct SearchModal: View {
    
    @Binding var isSeachModalOpened: Bool
    
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    @EnvironmentObject private var coreState: CoreState
    
    private enum Field {
        case query
    }
    
    @State private var searchQuery = ""
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .leading) {
                TextField("", text: $searchQuery)
                    .padding(.horizontal, 40)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .placeholder(when: searchQuery.isEmpty) {
                        Text("카페명을 정확히 입력해주세요")
                            .foregroundColor(.heavyGray)
                            .font(.caption)
                            .padding(.leading, 40)
                    }
                    .background(Color.moreLightGray)
                    .cornerRadius(.medium)
                    .focused($focusedField, equals: Field.query)
                
                HStack {
                    Button {
                        focusedField = nil
                        isSeachModalOpened = false
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.bold())
                            .padding(.small)
                    }
                    Spacer()
                    if !searchQuery.isEmpty {
                        Button {
                            searchQuery = ""
                        } label: {
                            Image(systemName: "x.circle.fill")
                                .font(.subtitle.bold())
                                .foregroundColor(.heavyGray)
                                .padding(.small)
                        }
                    }
                }
                .padding(.large)
            }
            .padding(.horizontal, .moreLarge)
            .frame(maxWidth: .infinity)
            .onChange(of: searchQuery) { newValue in
                if searchQuery.count > 1 {
                    Task {
                        await cafeViewModel.searchCafe(coreState: coreState, query: searchQuery)
                    }
                }
            }
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    VerticalSpacer(.large)
                    ForEach(cafeViewModel.searchCafeInfos, id: \.id) { cafeInfo in
                        Button {
                            isSeachModalOpened = false
                            focusedField = nil
                            Task {
                                await cafeViewModel.getNearbyCafeInfos(
                                    coreState: coreState,
                                    cameraPosition: NMFCameraPosition(
                                        NMGLatLng(
                                            lat: cafeInfo.latitude,
                                            lng: cafeInfo.longitude
                                        ),
                                        zoom: Zoom.large
                                    ),
                                    selectedCafeInfoId: cafeInfo.id,
                                    onSuccess: {
                                        cafeViewModel.cameraMoveToCafe(cafeInfoId: cafeInfo.id)
                                    }
                                )
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: .small) {
                                Text(cafeInfo.name)
                                    .font(.body.bold())
                                Text("\(cafeInfo.city) \(cafeInfo.gu) \(cafeInfo.address)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, .moreLarge)
                            .padding(.vertical, .large)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Divider()
                    }
                    VerticalSpacer(40)
                    if !searchQuery.isEmpty {
                        Text("원하는 카페가 없다면 바로 추가해보세요!")
                            .foregroundColor(.primary)
                            .font(.body.bold())
                            .underline()
                            .onTapGesture {
                                isSeachModalOpened = false
                                focusedField = nil
                                coreState.navigate(Screen.CafeInquiry.route)
                            }
                    }
                    VerticalSpacer(40)
                }
            }
            .scrollIndicators(.never)
        }
        .padding(.top, .large)
        .background(Color.white)
        .opacity(isSeachModalOpened ? 1 : 0)
        .animation(.easeInOut, value: isSeachModalOpened)
        .addKeyboardDownButton {
            focusedField = nil
        }
    }
}
