//
//  PopUpNotification.swift
//  Cafejari
//
//  Created by 안용우 on 2023/01/23.
//

import Foundation


struct PopUpNotification: Decodable {
    let order: Int
    let url: String
    let image: String
    let cafeInfoId: Int
}
extension PopUpNotification {
    func hasConnectedCafeInfo() -> Bool {
        return self.cafeInfoId != 0
    }
}
typealias PopUpNotifications = [PopUpNotification]

