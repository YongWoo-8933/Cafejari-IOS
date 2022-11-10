//
//  GuideGridView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI

struct GuideGridView: View {
    
    var body: some View {
        VStack{
            LazyVGrid(columns: GridItem(.flexible()).setGridColumn(columns: 2), spacing: 10) {
                ForEach(Guide.guides, id: \.images[0]) { guide in
                    NavigationLink {
                        GuideView(guideImages: guide.images)
                    } label: {
                        Image(guide.titleImage)
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
    }
}

struct Guide {
    let titleImage: String
    let images: [String]
}
extension Guide {
    static let guides: [Guide] = [
        Guide(titleImage: "master_guide_0", images: [ "master_guide_1", "master_guide_2", "master_guide_3", "master_guide_4", "master_guide_5", "master_guide_6"]),
        Guide(titleImage: "cafe_crowded_guide_0", images: ["cafe_crowded_guide_1", "cafe_crowded_guide_2", "cafe_crowded_guide_3", "cafe_crowded_guide_4", "cafe_crowded_guide_5", "cafe_crowded_guide_6", "cafe_crowded_guide_7"]),
        Guide(titleImage: "point_use_guide_0", images: ["point_use_guide_1", "point_use_guide_2", "point_use_guide_3", "point_use_guide_4", "point_use_guide_5", "point_use_guide_5", "point_use_guide_6"]),
        Guide(titleImage: "cafe_register_request_guide_0", images: ["cafe_register_request_guide_1", "cafe_register_request_guide_2", "cafe_register_request_guide_3", "cafe_register_request_guide_4", "cafe_register_request_guide_5", ]),
    ]
}
