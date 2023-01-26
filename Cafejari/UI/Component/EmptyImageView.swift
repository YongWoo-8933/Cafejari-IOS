//
//  EmptyImageView.swift
//  Cafejari
//
//  Created by 안용우 on 2023/01/23.
//

import SwiftUI

struct EmptyImageView: View {
    
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        VStack {
            Image("empty")
                .resizable()
                .scaledToFit()
                .frame(height: 148)
                .offset(x: 0, y: -.moreLarge)
            Text(text)
                .foregroundColor(.primary)
                .font(.title.bold())
        }
    }
}
