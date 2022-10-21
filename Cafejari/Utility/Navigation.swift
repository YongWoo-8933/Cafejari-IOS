//
//  ScreenRoute.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/13.
//

import Foundation

enum Screen {
    case Home
    case Profile
    case ProfileEdit
    case Promotion
    case Shop
    case ShoppingBag
    case GuideGrid
    case Guide
    case Information
    case UserMap
    case MasterMap
    case MasterRoom
    case Login
    case Register
    case Auth

    var route: String {
        switch self {
        case .Home:
            return "HomeView"
        case .Profile:
            return "ProfileView"
        case .ProfileEdit:
            return "ProfileEditView"
        case .Promotion:
            return "PromotionView"
        case .Shop:
            return "ShopView"
        case .ShoppingBag:
            return "ShoppingBagView"
        case .GuideGrid:
            return "GuideGridView"
        case .Guide:
            return "GuideView"
        case .Information:
            return "InformationView"
        case .UserMap:
            return "UserMapView"
        case .MasterMap:
            return "MasterMapView"
        case .MasterRoom:
            return "MasterRoomView"
        case .Login:
            return "LoginView"
        case .Register:
            return "RegisterView"
        case .Auth:
            return "RegisterView"
        }
    }
}

enum BottomTab {
    case UserMap
    case Home
    case MasterMap
    
    var name: String {
        switch self {
        case .Home:
            return "홈"
        case .UserMap:
            return "카페지도"
        case .MasterMap:
            return "마스터지도"
        }
    }
    
    var SFImage: String {
        switch self {
        case .Home:
            return "house"
        case .UserMap:
            return "map"
        case .MasterMap:
            return "flag"
        }
    }
}
