//
//  SecondaryButton.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/14.
//

import SwiftUI

struct BorderedCtaButton: View {
    let text: String
    let onClick: () -> Void
    
    var body: some View {
        Button {
            onClick()
        } label: {
            HStack {
                Text(text)
                    .font(.headline.bold())
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(.white)
            .roundBorder(cornerRadius: .medium, lineWidth: 1.5, borderColor: .primary)
        }
        .background(Color.white)
        .cornerRadius(.medium)
    }
}
