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
            HStack(spacing: 0) {
                if isSnackBarOpened {
                    switch(snackBarType) {
                        
                    case .alert:
                        Image(systemName: "checkmark.circle")
                            .font(.subtitle.bold())
                            .foregroundColor(.crowdedGreen)
                    case .error:
                        Image(systemName: "exclamationmark.circle")
                            .font(.subtitle.bold())
                            .foregroundColor(.error)
                    case .info:
                        Image(systemName: "info.circle")
                            .font(.subtitle.bold())
                            .foregroundColor(.lightGray)
                    }
                    
                    HorizontalSpacer(.medium)
                    
                    Text(content)
                        .font(.headline2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HorizontalSpacer(.large)
                    
                    Button {
                        onCloseButtonClick()
                    } label: {
                        Text("닫기")
                            .font(.headline2)
                            .foregroundColor(.lightGray)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: isSnackBarOpened ? .infinity : 0)
            .background(.black.opacity(0.6))
            .cornerRadius(.medium)
            .shadow(radius: 3)
            .padding(.horizontal, .large)
            .padding(.vertical, 40)
            .animation(.easeInOut(duration: .short), value: isSnackBarOpened)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}
