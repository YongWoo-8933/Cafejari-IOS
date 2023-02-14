//
//  ScreenRoute.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/13.
//

import Foundation

enum Screen {
    case ProfileEdit
    case MasterDetail
    case Promotion
    case ShoppingBag
    case GuideGrid
    case Guide
    case Information
    case MasterRoom
    case Login
    case Auth
    case CafeInquiry
    case CafeInquiryResult
    case PatchNote
    case FAQ
    case Inquiry
    case InquiryAnswer
    case PointResult
    case PermissionRequest
    case WebView
    case PointHistory

    var route: String {
        switch self {
        case .ProfileEdit:
            return "ProfileEditView"
        case .MasterDetail:
            return "MasterDetailView"
        case .Promotion:
            return "PromotionView"
        case .ShoppingBag:
            return "ShoppingBagView"
        case .GuideGrid:
            return "GuideGridView"
        case .Guide:
            return "GuideView"
        case .Information:
            return "InformationView"
        case .MasterRoom:
            return "MasterRoomView"
        case .Login:
            return "LoginView"
        case .Auth:
            return "RegisterView"
        case .CafeInquiry:
            return "CafeInquiryView"
        case .CafeInquiryResult:
            return "CafeInquiryResultView"
        case .PatchNote:
            return "PatchNoteView"
        case .FAQ:
            return "FAQView"
        case .Inquiry:
            return "InquiryView"
        case .InquiryAnswer:
            return "InquiryAnswerView"
        case .PointResult:
            return "PointResultView"
        case .PermissionRequest:
            return "PermissionRequestView"
        case .WebView:
            return "WebView"
        case .PointHistory:
            return "PointHistoryView"
        }
    }
}

enum BottomTab {
    case Map
    case LeaderBoard
    case Shop
    case Profile
    
    var name: String {
        switch self {
        case .Map:
            return "카페지도"
        case .LeaderBoard:
            return "랭킹"
        case .Shop:
            return "포인트상점"
        case .Profile:
            return "프로필"
        }
    }
    
    var SFImage: String {
        switch self {
        case .Map:
            return "map.fill"
        case .LeaderBoard:
            return "medal.fill"
        case .Shop:
            return "cart.fill"
        case .Profile:
            return "person.crop.circle"
        }
    }
}
