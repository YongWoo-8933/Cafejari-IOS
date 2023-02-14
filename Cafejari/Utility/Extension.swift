//
//  Extension.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/12.
//

import Foundation
import SwiftUI
import GooglePlaces

extension Color {
    init(hexString: String, opacity: Double = 1.0) {
        let hex: Int = Int(hexString, radix: 16)!
        let red = Double((hex >> 16) & 0xff) / 255
        let green = Double((hex >> 8) & 0xff) / 255
        let blue = Double((hex >> 0) & 0xff) / 255

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
    
    static let primary = Color(hexString: "50342B")
    static let onPrimary = Color(hexString: "A06C6C")
    static let secondary = Color(hexString: "C2948A")
    static let onSecondary = Color(hexString: "A06C6C")
    static let textPrimary = Color(hexString: "A38B83")
    static let textSecondary = Color(hexString: "BC796B")
    static let background = Color(hexString: "F6EBDA")
    static let error = Color(hexString: "FF6B6B")
    
    static let backgroundGray = Color(hexString: "F5F5F5")
    static let moreLightGray = Color(hexString: "ECECEC")
    static let lightGray = Color(hexString: "D4D4D4")
    static let gray = Color(hexString: "BCBCBC")
    static let heavyGray = Color(hexString: "A3A3A3")
    static let moreHeavyGray = Color(hexString: "6C6C6C")
    
    static let crowdedBlue = Color(hexString: "0656f7")
    static let crowdedGreen = Color(hexString: "8fe968")
    static let crowdedYellow = Color(hexString: "ffea56")
    static let crowdedOrange = Color(hexString: "fd9018")
    static let crowdedRed = Color(hexString: "f33203")
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static let crowdedGray = UIColor(rgb: 0xBCBCBC)
    static let crowdedBlue = UIColor(rgb: 0x0656f7)
    static let crowdedGreen = UIColor(rgb: 0x8fe968)
    static let crowdedYellow = UIColor(rgb: 0xffea56)
    static let crowdedOrange = UIColor(rgb: 0xfd9018)
    static let crowdedRed = UIColor(rgb: 0xf33203)
}

extension Font {
    static let title: Font = .system(size: 20, weight: .regular)
    static let subtitle: Font = .system(size: 18, weight: .regular)
    static let headline: Font = .system(size: 16, weight: .regular)
    static let headline2: Font = .system(size: 15, weight: .regular)
    static let body: Font = .system(size: 14, weight: .regular)
    static let body2: Font = .system(size: 13, weight: .regular)
    static let caption: Font = .system(size: 12, weight: .regular)
    static let caption2: Font = .system(size: 11, weight: .regular)
    
    func bold() -> Font {
        return self.weight(.bold)
    }
}

extension CGFloat {
    // corner radius size
    // spacing size
    static let small = 4.0
    static let medium = 8.0
    static let large = 12.0
    static let moreLarge = 20.0
}

extension Double {
    // animation duration
    static let short = 0.1
    static let long = 0.4
    
    func toZoomLevel() -> Int {
        if self >= 14.0 {
            return 1
        } else if self >= 12.0 {
            return 2
        } else if self >= 13.0 {
            return 4
        } else if self >= 12.0 {
            return 8
        } else {
            return 16
        }
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
    
    static let None = "_none"
    
    static let NoneImage = "https://cafejari.shop/_none"
    
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
    
    func hasSpecialChar() -> Bool {
        let pattern: String = "^[0-9a-zA-Z가-힣]*$"

        guard let _ = self.range(of: pattern, options: .regularExpression) else {
            return true
        }
        
        return false
    }
    
    func isNicknameLengthValid() -> Bool {
        return self.count <= 10 && self.count >= 2
    }
}

extension Date {
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension View {
    func addKeyboardDownButton(onClick: @escaping () -> Void) -> some View {
        modifier(KeyboardDownButton(onClick: onClick))
    }
    func roundBorder(cornerRadius: CGFloat, lineWidth: CGFloat, borderColor: Color) -> some View {
        modifier(RoundBorder(cornerRadius: cornerRadius, lineWidth: lineWidth, borderColor: borderColor))
    }
}

extension CLLocation? {
    func getDistance(latitude: Double, longitude: Double) -> Int {
        if let location = self {
            let earthRadius = 6371000.0
            let rad = Double.pi / 180
            var distance = sin(rad * latitude) * sin(rad * location.coordinate.latitude)
            distance += cos(rad * latitude) * cos(rad * location.coordinate.latitude) * cos(rad * (longitude - location.coordinate.longitude))
            let ret = earthRadius * acos(distance)
            return Int(round(ret))  // 미터 단위
            
        } else {
            return -1
        }
    }
}
