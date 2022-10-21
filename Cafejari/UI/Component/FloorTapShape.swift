//
//  FloorTapShape.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/16.
//

import SwiftUI

struct FloorTabShape0: Shape {
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: rect.maxX * 1 / 8, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX * 7 / 8, y: rect.minY))
        }
    }
}

struct FloorTabShape1: Shape {
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: rect.maxX * 7 / 8, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX * 1 / 8, y: rect.minY))
        }
    }
}
