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
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 16, height: 16)
        .border(Color.secondary, width: 1)
        .onTapGesture {
            withAnimation(.easeInOut(duration: .short)) {
                isChecked.toggle()
            }
        }
    }
}

