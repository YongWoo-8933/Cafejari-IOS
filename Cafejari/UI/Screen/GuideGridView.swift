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
                NavigationTitle(title: "유저 가이드북", leadingIconSystemName: "chevron.backward") {
                    coreState.popUp()
                }
                LazyVGrid(columns: GridItem(.flexible()).setGridColumn(columns: 2), spacing: .large) {
                    ForEach(Guide.guides, id: \.images[0]) { guide in
                        NavigationLink {
                            GuideView(guideImages: guide.images)
                        } label: {
                            Image(guide.titleImage)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(.medium)
                                .shadow(radius: 2)
                                .padding(.medium)
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
    let titleImage: String
    let images: [String]
}
extension Guide {
    static let guides: [Guide] = [
        Guide(titleImage: "master_guide_0", images: [ "master_guide_1", "master_guide_2", "master_guide_3", "master_guide_4", "master_guide_5", "master_guide_6", "master_guide_7"]),
        Guide(titleImage: "cafe_crowded_guide_0", images: ["cafe_crowded_guide_1", "cafe_crowded_guide_2", "cafe_crowded_guide_3", "cafe_crowded_guide_4", "cafe_crowded_guide_5"]),
        Guide(titleImage: "point_use_guide_0", images: ["point_use_guide_1", "point_use_guide_2", "point_use_guide_3", "point_use_guide_4", "point_use_guide_5", "point_use_guide_5", "point_use_guide_6"]),
        Guide(titleImage: "cafe_register_request_guide_0", images: ["cafe_register_request_guide_1", "cafe_register_request_guide_2", "cafe_register_request_guide_3", "cafe_register_request_guide_4"])
    ]
}
