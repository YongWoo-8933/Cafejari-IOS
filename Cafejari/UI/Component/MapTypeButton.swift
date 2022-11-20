//
//  MapTypeButton.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/16.
//

import SwiftUI

struct MapTypeButton: View {
    
    let isSelected: Bool
    let text: String
    let onClick: () -> Void
    
    var body: some View {
        Text(text)
            .font(.body.bold())
            .foregroundColor(isSelected ? .white : .moreHeavyGray)
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(isSelected ? Color.primary : Color.white)
            .cornerRadius(.medium)
            .roundBorder(cornerRadius: .medium, lineWidth: 1.5, borderColor: isSelected ? .clear : .lightGray)
            .onTapGesture {
                onClick()
            }
    }
}
