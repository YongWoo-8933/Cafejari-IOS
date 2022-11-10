//
//  Spacer.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/28.
//

import SwiftUI

struct HorizontalSpacer: View {
    
    let width: CGFloat
    let backgroundColor: Color
    
    init(_ width: CGFloat, backgroundColor: Color = Color.white) {
        self.width = width
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(backgroundColor.opacity(0.001))
                .frame(width: width)
        }
        .frame(maxHeight: 1)
    }
}

struct VerticalSpacer: View {
    
    let height: CGFloat
    let backgroundColor: Color
    
    init(_ height: CGFloat, backgroundColor: Color = Color.white) {
        self.height = height
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(backgroundColor.opacity(0.001))
                .frame(height: height)
        }
        .frame(maxWidth: 1)
    }
}
