//
//  RoundProfileImage.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/27.
//

import SwiftUI

struct RoundProfileImage: View {
    
    let size: CGFloat
    let image: String
    
    init(image: String, size: CGFloat) {
        self.image = image
        self.size = size
    }
    
    var body: some View {
        AsyncImage(
            url: URL(string: image),
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
        .shadow(radius: 1)
    }
}
