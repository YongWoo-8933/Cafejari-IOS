//
//  RoundTimeFrame.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/15.
//

import SwiftUI

struct RoundTimeFrame: View {
    let timeStringFrom: String
    let timeStringTo: String
    
    @Inject private var time: Time
    
    var body: some View {
        HStack {
            
            Text("\(time.getAMPMHourMinuteStringFrom(timeString: timeStringFrom)) ~ \(time.getAMPMHourMinuteStringFrom(timeString: timeStringTo))")
                .font(.caption.bold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 13)
        .frame(height: 28)
        .background(Color.gray)
        .cornerRadius(14)
    }
}
