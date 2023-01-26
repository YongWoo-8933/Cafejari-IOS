//
//  Crowded.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/21.
//

import Foundation
import SwiftUI

struct Crowded {
    let value: Int
    let color: Color
    let image: String
    let string: String
    let detailString: String
    let uiColor: UIColor
    let textColor: Color
    let uiTextColor: UIColor
}

extension Crowded {
    static var crowdedNegative = Crowded(value: -1, color: .gray, image: "crowded_marker_gray", string: "정보없음", detailString: "최근 혼잡도 정보가 없어요", uiColor: .gray, textColor: .white, uiTextColor: .white)
    static var crowdedZero = Crowded(value: 0, color: .crowdedBlue, image: "crowded_marker_0", string: "한적", detailString: "카페가 매우 한적해요", uiColor: .crowdedBlue, textColor: .white, uiTextColor: .white)
    static var crowdedOne = Crowded(value: 1, color: .crowdedGreen, image: "crowded_marker_1", string: "여유", detailString: "카페가 여유로워요", uiColor: .crowdedGreen, textColor: .black, uiTextColor: .black)
    static var crowdedTwo = Crowded(value: 2, color: .crowdedYellow, image: "crowded_marker_2", string: "보통", detailString: "보통이에요", uiColor: .crowdedYellow, textColor: .black, uiTextColor: .black)
    static var crowdedThree = Crowded(value: 3, color: .crowdedOrange, image: "crowded_marker_3", string: "혼잡", detailString: "카페가 사람들로 붐벼요", uiColor: .crowdedOrange, textColor: .white, uiTextColor: .white)
    static var crowdedFour = Crowded(value: 4, color: .crowdedRed, image: "crowded_marker_4", string: "만석", detailString: "카페가 거의 만석이에요", uiColor: .crowdedRed, textColor: .white, uiTextColor: .white)
    
    static var crowdedList = [crowdedNegative, crowdedZero, crowdedOne, crowdedTwo, crowdedThree, crowdedFour]
    static var crowdedListExceptNegative = [crowdedZero, crowdedOne, crowdedTwo, crowdedThree, crowdedFour]
}
