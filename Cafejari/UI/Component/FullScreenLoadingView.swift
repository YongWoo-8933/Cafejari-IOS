//
//  FullScreenLoadingView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/24.
//

import SwiftUI

struct FullScreenLoadingView: View {
    
    @Binding var loading: Bool
    
    let text: String
    
    var body: some View {
        if loading {
            VStack{
                ProgressView()
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                Text(text)
                    .foregroundColor(.white)
                    .padding(20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.5))
            .onTapGesture {  }
        }
    }
}
