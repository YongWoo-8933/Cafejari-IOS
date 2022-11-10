//
//  MapSheetCafeInfoView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/04.
//

import SwiftUI

struct MapSheetCafeInfoView: View {
    
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    
    @Binding var isBottomSheetOpened: Bool
    
    private let pasteboard = UIPasteboard.general
    
    var body: some View {
        
        if coreState.mapType == MapType.master {
            VStack {
                if !cafeViewModel.modalCafeInfo.isMasterAvailable() {
                    Text("이 카페는 모든 층에서 마스터들이 활동중입니다. 잠시 후에 다시 시도해주세요!")
                        .font(.body)
                } else {
                    HStack(spacing: 0) {
                        Text("지금은 ")
                            .font(.body)
                        ForEach(Array(cafeViewModel.modalCafeInfo.masterAvailableFloors().enumerated()), id: \.offset) { index, floor in
                            if index == cafeViewModel.modalCafeInfo.masterAvailableFloors().count - 1 {
                                Text("\(floor.toFloor())층이 활동 가능하네요!")
                                    .font(.body)
                            } else {
                                Text("\(floor.toFloor()), ")
                                    .font(.body)
                            }
                        }
                    }
                    Text("지금바로 포인트를 얻어보세요 > ")
                        .font(.caption)
                    +
                    Text(" 혼잡도 체크하러 가기")
                        .font(.subheadline.bold())
                }
            }
            .padding(15)
            .frame(maxWidth: .infinity)
            .background(.gray)
            .cornerRadius(15)
            .padding(10)
            .onTapGesture {
                if cafeViewModel.modalCafeInfo.isMasterAvailable() {
                    cafeViewModel.setCafeLogInfo(coreState: coreState)
                    isBottomSheetOpened = false
                    coreState.navigate(Screen.MasterRoom.route)
                }
            }
        }
        
        HStack {
            let cafe = cafeViewModel.modalCafeInfo.cafes.isEmpty ? Cafe.empty : cafeViewModel.modalCafeInfo.cafes[cafeViewModel.modalCafeIndex]
                
            Image(cafe.crowded.toCrowded().image)
                .resizable()
                .scaledToFit()
                .frame(height: 25)
            
            Text(cafeViewModel.modalCafeInfo.name)
                .font(.title3)
            
            Spacer()
        }
        .padding([.horizontal, .top], 15)
        .padding(.bottom, 25)
        
        if cafeViewModel.modalPreviewImages.isEmpty {
            // google place image 정보가 없는 경우
            ZStack {
                Image("cafe_picture_default")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                VStack {
                    Text("대체 이미지 입니다")
                        .foregroundColor(.white)
                        .padding(9)
                        .background(.black.opacity(0.5))
                        .cornerRadius(13)
                        .frame(height: 26)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(15)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .frame(height: 200)
            
        } else {
            // google place image 정보가 있는 경우
            ScrollView(.horizontal){
                LazyHStack{
                    ForEach(cafeViewModel.modalPreviewImages, id: \.self) { uiImage in
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    }
                    ForEach(cafeViewModel.modalMoreImages, id: \.self) { uiImage in
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
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
                                        .foregroundColor(.white)
                                        .padding()
                                }
                            }
                            .frame(width: 85, height: 200)
                            .background(.black.opacity(0.5))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            .scrollIndicators(.hidden)
        }
        
        VStack(spacing: 12) {
            HStack{
                let address = cafeViewModel.modalCafeInfo.city + " " +  cafeViewModel.modalCafeInfo.gu + " " +  cafeViewModel.modalCafeInfo.address
                Button{
                    pasteboard.string = address
                    coreState.showSnackBar(message: "주소가 복사되었습니다")
                } label: {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.gray)
                }
                Text(address)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 15)
            
            if let number = cafeViewModel.modalCafePhoneNumber {
                HStack{
                    Button{
                        if let encoded = "tel:\(number.toPhoneNumber())".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
                            openURL(myURL)
                        }
                    } label: {
                        Image(systemName: "phone")
                            .foregroundColor(.gray)
                    }
                    Text(number.toPhoneNumberWithHyphen())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
            } else {
                HStack{
                    Image(systemName: "phone")
                        .foregroundColor(.gray)
                    Text("-")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
            }
            
            if let url = cafeViewModel.modalCafeWebSite {
                HStack{
                    Image(systemName: "link")
                        .foregroundColor(.gray)
                    Text("홈페이지 >")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            openURL(url)
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
            } else {
                HStack{
                    Image(systemName: "link")
                        .foregroundColor(.gray)
                    Text("-")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
            }
            
            HStack{
                Image(systemName: "info.circle")
                    .foregroundColor(.gray)
                Text("정보 더보기 >")
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onTapGesture {
                let url = "https://m.search.naver.com/search.naver?sm=mtp_hty.top&where=m&query=" + cafeViewModel.modalCafeInfo.name
                if let encoded = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
                    openURL(myURL)
                }
            }
            .padding(.horizontal, 15)
        }
        .padding(.vertical, 15)
    }
}

