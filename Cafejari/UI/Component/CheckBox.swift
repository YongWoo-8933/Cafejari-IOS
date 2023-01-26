//
//  CheckBox.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/15.
//

import SwiftUI

struct CheckBox: View {
    
    @Binding var isChecked: Bool
    
    var body: some View {
        HStack {
            if isChecked {
                Image(systemName: "checkmark")
                    .font(.caption2.bold())
                    .foregroundColor(isChecked ? .secondary : .primary)
            }
        }
        .frame(width: 16, height: 16)
        .border(isChecked ? Color.secondary : Color.primary, width: 1)
        .onTapGesture {
            withAnimation(.easeInOut(duration: .short)) {
                isChecked.toggle()
            }
        }
    }
}

