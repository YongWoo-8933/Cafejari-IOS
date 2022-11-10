//
//  SnackBar.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/02.
//

import SwiftUI

enum SnackBarType {
    case alert, error, info
}

struct SnackBar: View {
    
    @Binding var isSnackBarOpened: Bool
    @Binding var snackBarType: SnackBarType
    @Binding var content: String
    let onCloseButtonClick: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                if isSnackBarOpened {
                    switch(snackBarType) {
                        
                    case .alert:
                        Image(systemName: "checkmark.circle")
                            .font(.title2.bold())
                            .foregroundColor(.green)
                    case .error:
                        Image(systemName: "exclamationmark.circle")
                            .font(.title2.bold())
                            .foregroundColor(.red)
                    case .info:
                        Image(systemName: "info.circle")
                            .font(.title2.bold())
                            .foregroundColor(.gray)
                    }
                    
                    HorizontalSpacer(15)
                    
                    Text(content.useNonBreakingSpace())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HorizontalSpacer(15)
                    
                    Button {
                        onCloseButtonClick()
                    } label: {
                        Text("닫기")
                    }
                }
            }
            .padding()
            .frame(maxWidth: isSnackBarOpened ? .infinity : 0)
            .background(.white)
            .cornerRadius(10)
            .shadow(radius: 3)
            .padding()
            .animation(.easeInOut(duration: 0.15), value: isSnackBarOpened)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}
