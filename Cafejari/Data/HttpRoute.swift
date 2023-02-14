//
//  HttpRoute.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/17.
//

import Foundation


struct HttpRoute {
    
    private let baseUrl = "https://cafejari.software"
    private let cafeBaseUrl, userBaseUrl, shopBaseUrl, infomationBaseUrl: String
    
    init() {
        cafeBaseUrl = baseUrl + "/cafe"
        userBaseUrl = baseUrl + "/user"
        shopBaseUrl = baseUrl + "/shop"
        infomationBaseUrl = baseUrl + "/information"
    }
    
    // core
    func blog() -> String{ return "https://blog.naver.com/cafejari22/"}
    func insta() -> String{ return "https://www.instagram.com/cafejari_official/"}
    func tos() -> String{ return "\(infomationBaseUrl)/tos/"}
    func privacyPolicy() -> String{ return "\(infomationBaseUrl)/privacy_policy/"}
    func privacyPolicyAgreement() -> String{ return "\(infomationBaseUrl)/privacy_policy_agreement/"}
    
    // guide
    func masterGuide() -> String { return "https://blog.naver.com/cafejari22/222879424057" }
    func crowdedGuide() -> String { return "https://blog.naver.com/cafejari22/222883642619" }
    func pointGuide() -> String { return "https://blog.naver.com/cafejari22/222883663747" }
    func cafeRegisterGuide() -> String { return "https://blog.naver.com/cafejari22/222883686897" }
    
    // user
    func refresh() -> String { return "\(userBaseUrl)/token/refresh/" }
    func user() -> String { return "\(userBaseUrl)/user/" }
    func kakaoLogin() -> String { return "\(userBaseUrl)/kakao/login/" }
    func googleLogin() -> String { return "\(userBaseUrl)/google/login/" }
    func appleLogin() -> String { return "\(userBaseUrl)/apple/login/" }
    func kakaoLoginFinish() -> String { return "\(userBaseUrl)/kakao/login/finish/" }
    func googleLoginFinish() -> String { return "\(userBaseUrl)/google/login/finish/" }
    func appleLoginFinish() -> String { return "\(userBaseUrl)/apple/login/finish/" }
    func preAuthorization() -> String { return "\(userBaseUrl)/pre_authorization/" }
    func makeNewProfile() -> String { return "\(userBaseUrl)/profile/" }
    func smsSend() -> String { return "\(userBaseUrl)/naver/sms/send/" }
    func smsAuth() -> String { return "\(userBaseUrl)/naver/sms/authentication/" }
    func authorization(profileId: Int) -> String { return "\(userBaseUrl)/profile/\(profileId)/authorization/" }
    func logout() -> String { return "\(userBaseUrl)/logout/" }
    func socialUserCheck() -> String { return "\(userBaseUrl)/social_user_check/" }
    func profile(id: Int) -> String { return "\(userBaseUrl)/profile/\(id)/" }
    func weekLeader() -> String { return "\(userBaseUrl)/week_leader/" }
    func myWeekRanking() -> String { return "\(userBaseUrl)/week_leader/my_ranking/" }
    func monthLeader() -> String { return "\(userBaseUrl)/month_leader/" }
    func myMonthRanking() -> String { return "\(userBaseUrl)/month_leader/my_ranking/" }
    
    // cafe
    func cafeInfo(lat: Double, lng: Double, zoomLevel: Int) -> String { return "\(cafeBaseUrl)/cafe_info/nearby_cafe_info/?latitude=\(lat)&longitude=\(lng)&zoom_level=\(zoomLevel)" }
    func masterRegistration() -> String { return "\(cafeBaseUrl)/cafe_master/registration/" }
    func crowded() -> String { return "\(cafeBaseUrl)/cafe_master/crowded/" }
    func cafeDetailLog(id: Int) -> String { return "\(cafeBaseUrl)/cafe_detail_log/\(id)/" }
    func masterExpiration() -> String { return "\(cafeBaseUrl)/cafe_master/expiration/" }
    func cafeLog(expired: Bool) -> String { return "\(cafeBaseUrl)/cafe_log/?expired=\(expired ? "True" : "False")" }
    func autoExpiredCafeLog() -> String { return "\(cafeBaseUrl)/auto_expired_log/" }
    func deleteAutoExpiredCafeLog(id: Int) -> String { return "\(cafeBaseUrl)/auto_expired_log/\(id)/" }
    func thumbsUp() -> String { return "\(cafeBaseUrl)/thumbs_up/" }
    
    // shop
    func item() -> String { return "\(shopBaseUrl)/item/" }
    func purchaseRequest() -> String { return "\(shopBaseUrl)/purchase_request/" }
    func deletePurchaseRequest(id: Int) -> String { return "\(shopBaseUrl)/purchase_request/\(id)/" }
    
    // infomation
    func iosVersion() -> String { return "\(infomationBaseUrl)/ios_app_version/" }
    func event() -> String { return "\(infomationBaseUrl)/event/" }
    func event_point_history() -> String { return "\(infomationBaseUrl)/event_point_history/" }
    func faq() -> String { return "\(infomationBaseUrl)/faq/" }
    func popUpNotification() -> String { return "\(infomationBaseUrl)/pop_up_notification_with_cafe_info/" }
    func onSaleCafe() -> String { return "\(infomationBaseUrl)/on_sale_cafe/" }
    func inquiryEtc() -> String { return "\(infomationBaseUrl)/inquiry_etc/" }
    func inquiryCafe() -> String { return "\(infomationBaseUrl)/inquiry_cafe/" }
    func deleteInquiryEtc(id: Int) -> String { return "\(infomationBaseUrl)/inquiry_etc/\(id)/" }
    func deleteInquiryCafe(id: Int) -> String { return "\(infomationBaseUrl)/inquiry_cafe/\(id)/" }
}
