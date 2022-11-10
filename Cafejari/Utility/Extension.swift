//
//  Extension.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/12.
//

import Foundation
import SwiftUI
import GoogleMaps
import GooglePlaces

extension Color {
    init(hexString: String, opacity: Double = 1.0) {
        let hex: Int = Int(hexString, radix: 16)!
        let red = Double((hex >> 16) & 0xff) / 255
        let green = Double((hex >> 8) & 0xff) / 255
        let blue = Double((hex >> 0) & 0xff) / 255

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
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
        zoom: GlobalZoom.Default.rawValue
    )
    
    static var kwangWoon = GMSCameraPosition.camera(
        withLatitude: 37.620769,
        longitude: 127.058921,
        zoom: GlobalZoom.Default.rawValue
    )
}

extension UIImage {
    
    func resizeImageTo(size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension Int {
    func toCrowded() -> Crowded {
        switch self {
        case 0: return Crowded.crowdedZero
        case 1: return Crowded.crowdedOne
        case 2: return Crowded.crowdedTwo
        case 3: return Crowded.crowdedThree
        case 4: return Crowded.crowdedFour
        default:
            return Crowded.crowdedNegative
        }
    }
    func toFloor() -> String {
        if self < 0 {
            return "B\(abs(self))"
        } else {
            return "\(self)"
        }
    }
    func getAMPM() -> String {
        if self < 12 {
            return "오전"
        } else {
            return "오후"
        }
    }
    func getHour() -> Int {
        if self == 0 {
            return 12
        } else if self <= 12 {
            return self
        } else {
            return self - 12
        }
    }
}

extension String {
    func toPhoneNumberWithHyphen() -> String {
        let returnNumber = self.replacingOccurrences(of: "+82 ", with: "")
        
        var count = 0

        for i in self {
            if i == "-" {
                count += 1
            }
        }
        
        return count == 2 ? "0\(returnNumber)" : returnNumber
    }
    
    func toPhoneNumber() -> String {
        var returnNumber = ""
        
        for i in self.toPhoneNumberWithHyphen() {
            if i != "-" {
                returnNumber += String(i)
            }
        }

        return returnNumber
    }
    
    func useNonBreakingSpace() -> String {
        return self.replacingOccurrences(of: " ", with: "\u{202F}\u{202F}")
    }
    

    func randomString(_ length: Int) -> String {
        let str = (0 ..< length).map{ _ in self.randomElement()! }
        return String(str)
    }
}

extension Date {
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
