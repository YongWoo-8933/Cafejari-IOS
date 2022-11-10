//
//  RoundClockFrame.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/27.
//

import SwiftUI

struct RoundClockFrame: View {
    
    let timeString: String
    
    @Inject private var time: Time
    
    var body: some View {
        HStack {
            Text("\(time.getAMPMHourMinuteStringFrom(timeString: timeString)) (\(time.getPassingHourMinuteStringFrom(timeString: timeString))전)")
                .font(.caption.bold())
                .foregroundColor(.black)
        }
        .padding(8)
        .frame(height: 32)
        .background(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}
