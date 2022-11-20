//
//  RoundClockFrame.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/27.
//

import SwiftUI

struct RoundCrowdedFrame: View {
    
    let crowded: Crowded
    let timeString: String
    
    @Inject private var time: Time
    
    var body: some View {
        HStack {
            Text(crowded.string)
                .font(.caption2.bold())
                .foregroundColor(crowded.textColor)
                .frame(width: 28, height: 28)
                .background(crowded.color)
                .clipShape(Circle())
                .clipped()
            
            Text("\(time.getAMPMHourMinuteStringFrom(timeString: timeString))")
                .font(.caption.bold())
                .foregroundColor(.black)
            Text("(\(time.getPassingHourMinuteStringFrom(timeString: timeString))전)")
                .font(.caption)
        }
        .padding(.leading, 4)
        .padding(.trailing, 8)
        .frame(height: 36)
        .background(.white)
        .roundBorder(cornerRadius: 18, lineWidth: 1, borderColor: .heavyGray)
    }
}
