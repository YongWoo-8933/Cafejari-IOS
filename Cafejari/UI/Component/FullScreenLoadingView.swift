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
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .frame(width: 44, height: 44)
            Text(text)
                .font(.subtitle.bold())
                .foregroundColor(.white)
                .padding(.moreLarge)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.5))
        .onTapGesture {  }
        .opacity(loading ? 1 : 0)
        .animation(.easeInOut, value: loading)
    }
}
