//
//  MapSheetCafeInfoView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/04.
//

import SwiftUI
import CachedAsyncImage

struct MapSheetCafeInfoView: View {
    
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    
    @Binding var isBottomSheetOpened: Bool
    
    @State private var isOpeningHourOpened = false
    @State private var isWallSocketInfoOpened = false
    
    private let pasteboard = UIPasteboard.general
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if cafeViewModel.modalCafeInfo.moreInfo.id != 0 {
                if cafeViewModel.modalCafeInfo.moreInfo.event1 != String.None ||
                    cafeViewModel.modalCafeInfo.moreInfo.event2 != String.None ||
                    cafeViewModel.modalCafeInfo.moreInfo.event3 != String.None {
                    Text("이 카페에서만 진행중인 이벤트")
                        .font(.body.bold())
                    
                    VerticalSpacer(16)
                    
                    if cafeViewModel.modalCafeInfo.moreInfo.event1 != String.None {
                        HStack(alignment: .top) {
                            Text("🎉")
                            Text(cafeViewModel.modalCafeInfo.moreInfo.event1)
                        }
                        VerticalSpacer(.medium)
                    }
                    if cafeViewModel.modalCafeInfo.moreInfo.event2 != String.None {
                        HStack(alignment: .top) {
                            Text("🎉")
                            Text(cafeViewModel.modalCafeInfo.moreInfo.event2)
                        }
                        VerticalSpacer(.medium)
                    }
                    if cafeViewModel.modalCafeInfo.moreInfo.event3 != String.None {
                        HStack(alignment: .top) {
                            Text("🎉")
                            Text(cafeViewModel.modalCafeInfo.moreInfo.event3)
                        }
                        VerticalSpacer(.medium)
                    }
                    
                    VerticalSpacer(28)
                }
                if cafeViewModel.modalCafeInfo.moreInfo.image != String.NoneImage {
                    CachedAsyncImage(
                        url: URL(string: cafeViewModel.modalCafeInfo.moreInfo.image),
                        content: { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .cornerRadius(.medium)
                        },
                        placeholder: {
                            ProgressView()
                        }
                    )
                    
                    VerticalSpacer(28)
                }
                if cafeViewModel.modalCafeInfo.moreInfo.notice1 != String.None ||
                    cafeViewModel.modalCafeInfo.moreInfo.notice2 != String.None ||
                    cafeViewModel.modalCafeInfo.moreInfo.notice3 != String.None {
                    Text("사장님의 한마디")
                        .font(.body.bold())
                    
                    VerticalSpacer(16)
                    
                    if cafeViewModel.modalCafeInfo.moreInfo.notice1 != String.None {
                        HStack(alignment: .top) {
                            Text("☝")
                            Text(cafeViewModel.modalCafeInfo.moreInfo.notice1)
                        }
                        VerticalSpacer(.medium)
                    }
                    if cafeViewModel.modalCafeInfo.moreInfo.notice2 != String.None {
                        HStack(alignment: .top) {
                            Text("☝")
                            Text(cafeViewModel.modalCafeInfo.moreInfo.notice2)
                        }
                        VerticalSpacer(.medium)
                    }
                    if cafeViewModel.modalCafeInfo.moreInfo.notice3 != String.None {
                        HStack(alignment: .top) {
                            Text("☝")
                            Text(cafeViewModel.modalCafeInfo.moreInfo.notice3)
                        }
                        VerticalSpacer(.medium)
                    }
                    
                    VerticalSpacer(28)
                }
            }
            
            Text("매장 정보")
                .font(.body.bold())
            
            VerticalSpacer(.small)
            
            if cafeViewModel.modalPreviewImagesLoading {
                VerticalSpacer(40)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .heavyGray))
                    .frame(width: 44, height: 44)
                VerticalSpacer(40)
            } else {
                // google place image 정보가 있는 경우
                if !cafeViewModel.modalPreviewImages.isEmpty {
                VerticalSpacer(.large)
                    ScrollView(.horizontal){
                        LazyHStack {
                            ForEach(cafeViewModel.modalPreviewImages, id: \.self) { uiImage in
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(.medium)
                            }
                            ForEach(cafeViewModel.modalMoreImages, id: \.self) { uiImage in
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(.medium)
                            }
                            if cafeViewModel.modalMoreImagesLoading {
                                ProgressView()
                                    .padding(30)
                            }
                            if cafeViewModel.modalImageMetaData.count > 3 &&
                                cafeViewModel.modalMoreImages.isEmpty &&
                                !cafeViewModel.modalMoreImagesLoading {
                                Button {
                                    cafeViewModel.getModalCafeMoreImages()
                                } label: {
                                    ZStack {
                                        VStack {
                                            Image(systemName: "ellipsis")
                                                .foregroundColor(.white)
                                            Text("더보기")
                                                .font(.caption.bold())
                                                .foregroundColor(.white)
                                                .padding(.medium)
                                        }
                                    }
                                    .frame(width: 85, height: 200)
                                    .background(.black.opacity(0.5))
                                    .cornerRadius(.medium)
                                }
                            }
                        }
                    }
                    .scrollIndicators(.never)
                }
            }
            
            VerticalSpacer(.moreLarge)
            
            VStack(spacing: .large) {
                HStack {
                    let address = cafeViewModel.modalCafeInfo.city + " " +  cafeViewModel.modalCafeInfo.gu + " " +  cafeViewModel.modalCafeInfo.address
                    Button {
                        pasteboard.string = address
                        cafeViewModel.showModalSnackBar(message: "주소가 복사되었습니다")
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.gray)
                    }
                    Text(address)
                        .foregroundColor(.moreHeavyGray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if let weekDayTexts = cafeViewModel.modalCafePlace?.openingHours?.weekdayText {
                    HStack(alignment: .top) {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                        VStack(alignment: .leading, spacing: 2) {
                            if !weekDayTexts.isEmpty {
                                Button {
                                    isOpeningHourOpened.toggle()
                                } label: {
                                    HStack {
                                        Text(weekDayTexts[0])
                                            .foregroundColor(.moreHeavyGray)
                                        Image(systemName: isOpeningHourOpened ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.moreHeavyGray)
                                    }
                                }
                                if isOpeningHourOpened {
                                    ForEach(Array(weekDayTexts.enumerated()), id: \.offset) { index, text in
                                        if index != 0 {
                                            Text(text)
                                                .foregroundColor(.moreHeavyGray)
                                        }
                                    }
                                }
                            }
                        }
                        .animation(Animation.easeInOut, value: isOpeningHourOpened)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if !cafeViewModel.modalCafeInfo.getWallSocketInfoExistCafes().isEmpty {
                    HStack(alignment: .top) {
                        Image(systemName: "powerplug")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .padding(.top, 2)
                        VStack(alignment: .leading, spacing: 2) {
                            Button {
                                isWallSocketInfoOpened.toggle()
                            } label: {
                                HStack {
                                    Text("층별 콘센트 보급율")
                                        .foregroundColor(.moreHeavyGray)
                                    Image(systemName: isWallSocketInfoOpened ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.moreHeavyGray)
                                }
                            }
                            .padding(.bottom, 2)
                            if isWallSocketInfoOpened {
                                ForEach(cafeViewModel.modalCafeInfo.getWallSocketInfoExistCafes(), id: \.id) { cafe in
                                    HStack(spacing: 0) {
                                        Text(cafe.floor.toFloor() + "층:")
                                            .frame(width: 34, alignment: .leading)
                                            .foregroundColor(.moreHeavyGray)
                                        Text(cafe.wallSocket)
                                            .foregroundColor(.moreHeavyGray)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .animation(Animation.easeInOut, value: isWallSocketInfoOpened)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if !cafeViewModel.modalCafeInfo.getRestroomInfoExistCafes().isEmpty {
                    HStack(alignment: .top) {
                        Image(systemName: "figure.dress.line.vertical.figure")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .padding(.top, 2)
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(cafeViewModel.modalCafeInfo.getRestroomInfoExistCafes(), id: \.id) { cafe in
                                HStack(spacing: 0) {
                                    Text(cafe.floor.toFloor() + "층:")
                                        .frame(width: 34, alignment: .leading)
                                        .foregroundColor(.moreHeavyGray)
                                    Text(cafe.restroom)
                                        .foregroundColor(.moreHeavyGray)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack{
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                    Text("매장 상세정보")
                        .underline()
                        .foregroundColor(.moreHeavyGray)
                        .onTapGesture {
                            isBottomSheetOpened = false
                            coreState.navigateToWebView(
                                "매장 상세 정보",
                                "https://m.search.naver.com/search.naver?sm=mtp_hty.top&where=m&query=\(cafeViewModel.modalCafeInfo.name)"
                            )
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.moreLarge)
        .padding(.vertical, .large)
        
        if !cafeViewModel.modalImageMetaData.isEmpty {
            VerticalSpacer(40)
            Text("위 사진은 google place api에서 제공되며, google map 닉네임 \(cafeViewModel.modalAttributions)에게 저작권이 있습니다. 무단으로 사용 및 배포할 경우 google maps platform 서비스 정책에 따라 책임을 물을 수 있습니다.")
                .font(.caption2)
                .frame(maxWidth: .infinity)
                .padding(.moreLarge)
                .foregroundColor(.lightGray)
        }
    }
}

