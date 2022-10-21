//
//  Master.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/14.
//

import Foundation

class Master: ObservableObject{
    
    @Published var isMasterActivated: Bool
    @Published var masterCafeLog: String
    
    init() {
        isMasterActivated = false
        masterCafeLog = "어딘가 신촌점"
    }
    
    func activateMaster(cafeId: Int) -> String {
        isMasterActivated = true
        return "여기 네 카페로그야"
    }
    
    func expireMaster(cafeLog: String) {
        isMasterActivated = false
    }
}
