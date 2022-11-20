//
//  NavigationTitle.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/17.
//

import SwiftUI

struct NavigationTitle: View {
    
    let title: String
    let leadingIconSystemName: String
    let onLeadingIconClick: () -> Void
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title.bold())
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            
            Image(systemName: leadingIconSystemName)
                .font(.title)
                .onTapGesture {
                    onLeadingIconClick()
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.moreLarge)
        .background(Color.background)
    }
}
