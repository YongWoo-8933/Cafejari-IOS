//
//  Extension.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/12.
//

import Foundation
import SwiftUI
import GoogleMaps

extension Color {
    init(hexString: String, opacity: Double = 1.0) {
        let hex: Int = Int(hexString, radix: 16)!
        let red = Double((hex >> 16) & 0xff) / 255
        let green = Double((hex >> 8) & 0xff) / 255
        let blue = Double((hex >> 0) & 0xff) / 255

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

extension UserResponse {
    func getUser() -> User {
        let profile = self.profile ?? ProfileResponse.empty
        
        return User(
            userId: self.id,
            profileId: profile.id,
            dateJoined: self.date_joined,
            email: self.email,
            lastLogin: self.last_login,
            authorization: self.authorization,
            nickname: profile.nickname ?? "",
            fcmToken: profile.fcm_token,
            phoneNumber: profile.phone_number ?? "00000000",
            image: profile.image,
            point: profile.point,
            grade: profile.grade,
            activity: profile.activity
        )
    }
}

extension GridItem {
    func setGridColumn(columns: Int) -> [GridItem] {
        var list: [GridItem] = []
        for _ in 0 ..< columns {
            list.append( self )
        }
        return list
    }
}

extension GMSCameraPosition  {
    static var sinchon = GMSCameraPosition.camera(
        withLatitude: 37.55649747287372,
        longitude: 126.93710302643744,
        zoom: 16.5
    )
 }

extension GMSMarker {
    func setIconSize(scaledToSize newSize: CGSize) {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        icon?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        icon = newImage
    }
}
