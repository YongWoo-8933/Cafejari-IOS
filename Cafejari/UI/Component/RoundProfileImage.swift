//
//  RoundProfileImage.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/27.
//

import SwiftUI

struct RoundProfileImage: View {
    
    @EnvironmentObject private var coreState: CoreState
    
    let size: CGFloat
    
    init(_ size: CGFloat) {
        self.size = size
    }
    
    var body: some View {
        AsyncImage(
            url: URL(string: coreState.user.image),
            content: { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .clipped()
            },
            placeholder: {
                Image("blank_profile_picture")
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .clipped()
            }
        )
    }
}
