//
//  GuideGridView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI
import GoogleMobileAds

struct GuideGridView: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var adViewModel: AdViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                NavigationTitle(
                    title: "유저 가이드북",
                    leadingIconSystemName: "chevron.backward",
                    onLeadingIconClick: {
                        coreState.popUp()
                    }
                )
                LazyVGrid(columns: GridItem(.flexible()).setGridColumn(columns: 2), spacing: .large) {
                    ForEach(Guide.guides, id: \.titleImage) { guide in
                        Image(guide.titleImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(.medium)
                            .shadow(radius: 2)
                            .padding(.medium)
                            .onTapGesture {
                                coreState.navigateToWebView(guide.title, guide.url)
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.moreLarge)
                
                Spacer()
            }
            .navigationBarBackButtonHidden()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            AdBannerView()
                .frame(width: UIScreen.main.bounds.width, height: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width).size.height)
                .offset(x: 0, y: .moreLarge)
        }
        .task {
            adViewModel.loadBanner()
        }
    }
}

struct Guide {
    let title: String
    let titleImage: String
    let url: String
}
extension Guide {
    static let guides: [Guide] = [
        Guide(title: "마스터 활동 가이드", titleImage: "master_guide_0", url: HttpRoute().masterGuide()),
        Guide(title: "혼잡도 정보 활용 가이드", titleImage: "cafe_crowded_guide_0", url: HttpRoute().crowdedGuide()),
        Guide(title: "포인트 사용 가이드", titleImage: "point_use_guide_0", url: HttpRoute().pointGuide()),
        Guide(title: "카페 등록 가이드", titleImage: "cafe_register_request_guide_0", url: HttpRoute().cafeRegisterGuide())
    ]
}
