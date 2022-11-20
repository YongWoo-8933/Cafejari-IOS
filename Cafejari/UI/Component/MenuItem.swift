//
//  MenuItem.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/16.
//

import SwiftUI

struct MenuItem: View {
    
    let text: String
    let iconSystemName: String
    let onClick: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(text)
                Spacer()
                Image(systemName: iconSystemName)
            }
            .padding(.horizontal, 16)
            .frame(width: 140, height: 48, alignment: .leading)
            .background(Color.white)
            .onTapGesture {
                onClick()
            }
            Divider()
        }
    }
}
