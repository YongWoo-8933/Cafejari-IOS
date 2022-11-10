//
//  File.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/30.
//

import Foundation
import SwiftUI

final class ApplicationUtility {
    
    static var rootViewController: UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}
