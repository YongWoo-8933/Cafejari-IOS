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
    
    private let pasteboard = UIPasteboard.general
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if cafeViewModel.modalCafeInfo.moreInfo.id != 0 {
                if cafeViewModel.modalCafeInfo.moreInfo.event1 != String.None ||
                    cafeViewModel.modalCafeInfo.moreInfo.event2 != String.None ||
                    cafeViewModel.modalCafeInfo.moreInfo.event3 != String.None {
                    Text("이 카페에서만 진행중인")
                        .font(.body.bold())
                    +
                    Text("이벤트가 있어요!")
                    
                    VerticalSpacer(.large)
                    
                    if cafeViewModel.modalCafeInfo.moreInfo.event1 != String.None {
                        Text("🎉  \(cafeViewModel.modalCafeInfo.moreInfo.event1)")
                        VerticalSpacer(.small)
                    }
                    if cafeViewModel.modalCafeInfo.moreInfo.event2 != String.None {
                        Text("🎉  \(cafeViewModel.modalCafeInfo.moreInfo.event2)")
                        VerticalSpacer(.small)
                    }
                    if cafeViewModel.modalCafeInfo.moreInfo.event3 != String.None {
                        Text("🎉  \(cafeViewModel.modalCafeInfo.moreInfo.event3)")
                        VerticalSpacer(.small)
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
                    
                    VerticalSpacer(.large)
                    
                    if cafeViewModel.modalCafeInfo.moreInfo.notice1 != String.None {
                        Text("☝  \(cafeViewModel.modalCafeInfo.moreInfo.notice1)")
                        VerticalSpacer(.small)
                    }
                    if cafeViewModel.modalCafeInfo.moreInfo.notice2 != String.None {
                        Text("☝  \(cafeViewModel.modalCafeInfo.moreInfo.notice2)")
                        VerticalSpacer(.small)
                    }
                    if cafeViewModel.modalCafeInfo.moreInfo.notice3 != String.None {
                        Text("☝  \(cafeViewModel.modalCafeInfo.moreInfo.notice3)")
                        VerticalSpacer(.small)
                    }
                    
                    VerticalSpacer(28)
                }
            }
            
            Text("카페 매장정보")
                .font(.body.bold())
            +
            Text("를 알려드려요")
            
            VerticalSpacer(.small)
            
            if !cafeViewModel.modalPreviewImages.isEmpty {
                // google place image 정보가 있는 경우
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
            
            VerticalSpacer(.large)
            
            VStack(spacing: .medium) {
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
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Image(systemName: "phone")
                        .foregroundColor(.gray)
                    if let number = cafeViewModel.modalCafePhoneNumber {
                        Text(number.toPhoneNumberWithHyphen())
                            .underline()
                            .foregroundColor(.crowdedBlue)
                            .onTapGesture {
                                if let encoded = "tel:\(number.toPhoneNumber())".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
                                    openURL(myURL)
                                }
                            }
                    } else {
                        Text("-")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack{
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                    Text("정보 더보기")
                        .underline()
                        .foregroundColor(.crowdedBlue)
                        .onTapGesture {
                            let url = "https://m.search.naver.com/search.naver?sm=mtp_hty.top&where=m&query=" + cafeViewModel.modalCafeInfo.name
                            if let encoded = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
                                openURL(myURL)
                            }
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.moreLarge)
        .padding(.vertical, .large)
        
        if !cafeViewModel.modalImageMetaData.isEmpty {
            Text("위 사진은 google place api에서 제공되며, google map 닉네임 \(cafeViewModel.modalAttributions)에게 저작권이 있습니다. 무단으로 사용 및 배포할 경우 google maps platform 서비스 정책에 따라 책임을 물을 수 있습니다.")
                .font(.caption2)
                .frame(maxWidth: .infinity)
                .padding(.moreLarge)
                .foregroundColor(.lightGray)
        }
    }
}

