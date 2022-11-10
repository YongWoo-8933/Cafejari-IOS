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
    let uiColor: UIColor
}

extension Crowded {
    static var crowdedNegative = Crowded(value: -1, color: Color.gray, image: "crowded_marker_gray", string: "정보없음", uiColor: UIColor.gray)
    static var crowdedZero = Crowded(value: 0, color: Color.blue, image: "crowded_marker_0", string: "한적", uiColor: UIColor.blue)
    static var crowdedOne = Crowded(value: 1, color: Color.green, image: "crowded_marker_1", string: "여유", uiColor: UIColor.green)
    static var crowdedTwo = Crowded(value: 2, color: Color.yellow, image: "crowded_marker_2", string: "보통", uiColor: UIColor.yellow)
    static var crowdedThree = Crowded(value: 3, color: Color.orange, image: "crowded_marker_3", string: "혼잡", uiColor: UIColor.orange)
    static var crowdedFour = Crowded(value: 4, color: Color.red, image: "crowded_marker_4", string: "만석", uiColor: UIColor.red)
    
    static var crowdedList = [crowdedNegative, crowdedZero, crowdedOne, crowdedTwo, crowdedThree, crowdedFour]
    static var crowdedListExceptNegative = [crowdedZero, crowdedOne, crowdedTwo, crowdedThree, crowdedFour]
}
