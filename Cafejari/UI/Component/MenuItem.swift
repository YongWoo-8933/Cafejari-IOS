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
        HStack {
            Image(systemName: iconSystemName)
            Spacer()
            Text(text)
            Spacer()
        }
        .padding(.horizontal, .large)
        .frame(width: 140, height: 48, alignment: .leading)
        .background(Color.white)
        .roundBorder(cornerRadius: 0, lineWidth: 1, borderColor: Color.moreLightGray)
        .onTapGesture {
            onClick()
        }
    }
}
