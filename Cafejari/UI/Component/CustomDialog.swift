//
//  CustomDialog.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/02.
//

import SwiftUI

struct CustomDialog: View {
    
    @Binding var isDialogVisible: Bool
    
    let content: String
    let positiveButtonText: String
    let negativeButtonText: String
    let onPositivebuttonClick: () -> Void
    let onNegativebuttonClick: () -> Void
    let onDismiss: () -> Void
    
    var width = UIScreen.main.bounds.size.width * 0.6
    var bgColor: Color = Color.white
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(.black.opacity(0.8))
            .opacity(isDialogVisible ? 1 : 0)
            .animation(.easeInOut.delay(0.1), value: isDialogVisible)
            .onTapGesture {
                onDismiss()
                isDialogVisible = false
            }
            
            VStack {
                Text(content)
                VerticalSpacer(15)
                HStack {
                    RoundButton(
                        buttonHeight: 56,
                        text: negativeButtonText,
                        textColor: .brown,
                        backgroundColor: .white
                    ) {
                        onNegativebuttonClick()
                        isDialogVisible = false
                    }
                    
                    RoundButton(
                        buttonHeight: 56,
                        text: positiveButtonText,
                        textColor: .white,
                        backgroundColor: .brown
                    ) {
                        onPositivebuttonClick()
                        isDialogVisible = false
                    }
                }
            }
            .padding(15)
            .frame(width: width)
            .background(bgColor)
            .cornerRadius(10)
            .shadow(radius: 3)
            .opacity(isDialogVisible ? 1 : 0)
            .animation(.easeInOut.delay(0.1), value: isDialogVisible)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
