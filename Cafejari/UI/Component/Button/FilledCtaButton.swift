//
//  PrimaryButton.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/14.
//

import SwiftUI

struct FilledCtaButton: View {
    
    let text: String
    let backgroundColor: Color
    let isProgress: Bool
    let onClick: () -> Void
    
    init(text: String, backgroundColor: Color, isProgress: Bool = false, onClick: @escaping () -> Void) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.isProgress = isProgress
        self.onClick = onClick
    }
    
    var body: some View {
        Button {
            onClick()
        } label: {
            HStack {
                if isProgress {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(text)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(backgroundColor)
            .cornerRadius(.medium)
        }
        .background(Color.white)
        .cornerRadius(.medium)
    }
}
