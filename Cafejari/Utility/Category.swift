//
//  Category.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/19.
//

import Foundation

struct ItemCategory: Identifiable {
    
    let id: UUID = UUID()
    let name, image, icon: String
}

struct InformationCategory: Identifiable {
    
    let id: UUID = UUID()
    let name, image: String
}

extension ItemCategory {
    
    static let itemCategories = [
        ItemCategory(name: "커피", image: "category_coffee", icon: "cup.and.saucer"),
        ItemCategory(name: "케이크", image: "category_cake", icon: "birthday.cake"),
        ItemCategory(name: "금액권", image: "category_giftcard", icon: "creditcard"),
        ItemCategory(name: "아이스크림", image: "category_icecream", icon: "snowflake"),
        ItemCategory(name: "디저트", image: "category_dessert", icon: "fork.knife"),
        ItemCategory(name: "논커피", image: "category_noncoffee", icon: "wineglass"),
    ]
}

extension InformationCategory {
        
    static let informationCategories = [
        InformationCategory(name: "가이드", image: "guide_icon"),
        InformationCategory(name: "포인트 정책", image: "point_icon"),
        InformationCategory(name: "주의사항", image: "warnning_icon"),
        InformationCategory(name: "문의하기", image: "support_icon"),
    ]
}

struct Guide: Identifiable {
    let id: UUID = UUID()
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
