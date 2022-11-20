//
//  CustomDialog.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/02.
//

import SwiftUI

struct Dialog: View {
    
    @Binding var isDialogVisible: Bool
    
    let positiveButtonText: String
    let negativeButtonText: String
    let onPositivebuttonClick: () -> Void
    let onNegativebuttonClick: () -> Void
    let onDismiss: () -> Void
    let content: () -> Text
    
    var body: some View {
        let width = UIScreen.main.bounds.size.width * 0.75
        ZStack {
            ZStack {
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.5))
            .opacity(isDialogVisible ? 1 : 0)
            .onTapGesture {
                isDialogVisible = false
                onDismiss()
            }
            
            VStack {
                content()
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 25)
                    .padding(.horizontal, .large)
                HStack(spacing: 0) {
                    if negativeButtonText.isEmpty {
                        Button {
                            isDialogVisible = false
                            onPositivebuttonClick()
                        } label: {
                            Text(positiveButtonText)
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .frame(width: width, height: 54)
                        }
                    } else {
                        Button {
                            isDialogVisible = false
                            onNegativebuttonClick()
                        } label: {
                            Text(negativeButtonText)
                                .font(.headline.bold())
                                .foregroundColor(.onSecondary)
                                .frame(width: width / 2, height: 54)
                        }
                        
                        Button {
                            isDialogVisible = false
                            onPositivebuttonClick()
                        } label: {
                            Text(positiveButtonText)
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .frame(width: width / 2, height: 54)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.secondary)
            }
            .frame(width: width)
            .background(.white)
            .cornerRadius(.moreLarge)
            .shadow(radius: 3)
            .opacity(isDialogVisible ? 1 : 0)
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.easeInOut, value: isDialogVisible)
    }
}
