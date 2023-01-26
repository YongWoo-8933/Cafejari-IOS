//
//  RoundedIconButton.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/24.
//

import SwiftUI

struct RoundButton: View {
    let iconSystemName: String?
    let text: String
    let foregroundColor: Color
    let backgroundColor: Color
    let onClick: () -> Void
    
    init(iconSystemName: String? = nil, text: String = "", foregroundColor: Color = .white, backgroundColor: Color = .primary, onClick: @escaping () -> Void) {
        self.iconSystemName = iconSystemName
        self.text = text
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.onClick = onClick
    }
    
    var body: some View {
        Button {
            onClick()
        } label: {
            HStack{
                if let iconSystemName = iconSystemName {
                    Image(systemName: iconSystemName)
                        .font(.headline2.bold())
                        .frame(height: 15)
                        .foregroundColor(foregroundColor)
                }
                if !text.isEmpty {
                    Text(text)
                        .foregroundColor(foregroundColor)
                        .font(.caption2.bold())
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(backgroundColor)
            .cornerRadius(16)
        }
        .background(Color.white)
        .cornerRadius(16)
    }
}
