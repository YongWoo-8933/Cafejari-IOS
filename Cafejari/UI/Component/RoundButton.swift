//
//  RoundedIconButton.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/24.
//

import SwiftUI

struct RoundButton: View {
    let buttonHeight: CGFloat
    let iconSystemName: String?
    let iconColor: Color
    let text: String
    let textColor: Color
    let backgroundColor: Color
    let onClick: () -> Void
    
    init(buttonHeight: CGFloat, iconSystemName: String? = nil, iconColor: Color = Color.black, text: String = "", textColor: Color = Color.black, backgroundColor: Color = Color.white, onClick: @escaping () -> Void) {
        self.buttonHeight = buttonHeight
        self.iconSystemName = iconSystemName
        self.iconColor = iconColor
        self.text = text
        self.textColor = textColor
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
                        .font(.callout.weight(.bold))
                        .frame(width: buttonHeight / 2, height: buttonHeight / 2)
                        .foregroundColor(iconColor)
                }
                if !text.isEmpty {
                    Text(text)
                        .foregroundColor(textColor)
                }
            }
        }
        .padding(.horizontal, 10)
        .frame(height: buttonHeight)
        .background(backgroundColor)
        .cornerRadius(buttonHeight / 2 + 10)
        .shadow(radius: 1)
    }
}
