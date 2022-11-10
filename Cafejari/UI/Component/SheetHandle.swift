//
//  SheetHandle.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/24.
//

import SwiftUI

struct SheetHandle: View {
    var body: some View {
        Rectangle()
            .fill(.gray)
            .frame(width: 44, height: 5)
            .cornerRadius(2.5)
            .padding(8)
    }
}
