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
                        .frame(width: geo.size.width / 5, height: 8)
                        .cornerRadius(4)
                        .background(crowded.color)
                        .roundBorder(cornerRadius: 0, lineWidth: 1, borderColor: .white)
                    }
                }
                .frame(width: geo.size.width, height: 8)
                .background(Color.white)
                .cornerRadius(.small)
                .roundBorder(cornerRadius: 4, lineWidth: 2, borderColor: .white)
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

