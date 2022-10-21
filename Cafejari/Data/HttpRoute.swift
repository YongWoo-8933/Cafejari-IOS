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
    
    // user
    func refresh() -> String { return "\(userBaseUrl)/token/refresh/" }
    func user() -> String { return "\(userBaseUrl)/user/" }
    func kakaoLogin() -> String { return "\(userBaseUrl)/kakao/login/" }
    func kakaoLoginFinish() -> String { return "\(userBaseUrl)/kakao/login/finish/" }
    func makeNewProfile() -> String { return "\(userBaseUrl)/profile/" }
    func smsSend() -> String { return "\(userBaseUrl)/naver/sms/send/" }
    func smsAuth() -> String { return "\(userBaseUrl)/naver/sms/authentication/" }
    func authorization(profileId: Int) -> String { return "\(userBaseUrl)/profile/\(profileId)/authorization/" }
    
    // cafe
    func cafeInfo() -> String { return "\(cafeBaseUrl)/cafe_info/" }
    
    // shop
    func item() -> String { return "\(shopBaseUrl)/item/" }
    
    // infomation
    func event() -> String { return "\(infomationBaseUrl)/event/" }
    func randomSaying() -> String { return "\(infomationBaseUrl)/random_saying/" }
    func randomImageSaying() -> String { return "\(infomationBaseUrl)/random_image_saying/" }
    func pointPolicy() -> String { return "\(infomationBaseUrl)/point_policy/" }
    func faq() -> String { return "\(infomationBaseUrl)/faq/" }
}
