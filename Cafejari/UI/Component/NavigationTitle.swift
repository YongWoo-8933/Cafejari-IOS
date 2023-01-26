//
//  NavigationTitle.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/17.
//

import SwiftUI

struct NavigationTitle: View {
    
    let title: String
    let leadingIconSystemName: String?
    let onLeadingIconClick: () -> Void
    let trailingIconSystemName: String?
    let onTrailingIconClick: () -> Void
    
    init(title: String, leadingIconSystemName: String? = nil, onLeadingIconClick: @escaping () -> Void = {}, trailingIconSystemName: String? = nil, onTrailingIconClick: @escaping () -> Void = {}) {
        self.title = title
        self.leadingIconSystemName = leadingIconSystemName
        self.onLeadingIconClick = onLeadingIconClick
        self.trailingIconSystemName = trailingIconSystemName
        self.onTrailingIconClick = onTrailingIconClick
    }
    
    var body: some View {
        ZStack {
            HStack {
                Text(title)
                    .font(.title.bold())
                    .foregroundColor(.primary)
            }
            
            if let leadingIconSystemName = leadingIconSystemName {
                HStack {
                    Image(systemName: leadingIconSystemName)
                        .font(.title)
                        .onTapGesture {
                            onLeadingIconClick()
                        }
                }
                .frame(maxWidth: .infinity, alignment: Alignment.leading)
            }
            
            if let trailingIconSystemName = trailingIconSystemName {
                HStack {
                    Image(systemName: trailingIconSystemName)
                        .font(.title)
                        .onTapGesture {
                            onTrailingIconClick()
                        }
                }
                .frame(maxWidth: .infinity, alignment: Alignment.trailing)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.moreLarge)
        .background(Color.background)
    }
}
