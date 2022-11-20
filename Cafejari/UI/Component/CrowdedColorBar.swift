//
//  CrowdedColorBar.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/16.
//

import SwiftUI

struct CrowdedColorBar: View {
    var body: some View {
        VStack {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ForEach(Crowded.crowdedListExceptNegative, id: \.value) { crowded in
                        HStack {
                            
                        }
                        .frame(width: geo.size.width / 5, height: 10)
                        .cornerRadius(5)
                        .background(crowded.color)
                    }
                }
                .frame(width: geo.size.width, height: 10)
                .background(Color.white)
                .cornerRadius(.small)
                .roundBorder(cornerRadius: 5, lineWidth: 2, borderColor: .white)
                .shadow(radius: 1)
            }
                
            HStack {
                Text(Crowded.crowdedZero.string)
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(width: 36, height: 20)
                    .background(Color.heavyGray)
                    .cornerRadius(10)
                Spacer()
                Text(Crowded.crowdedFour.string)
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(width: 36, height: 20)
                    .background(Color.heavyGray)
                    .cornerRadius(10)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

