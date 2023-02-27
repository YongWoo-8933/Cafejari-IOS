//
//  Modifier.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/15.
//

import Foundation
import SwiftUI
import Combine

struct TopNavigationBackButton: ViewModifier {
    
    let onClick: () -> Void
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onClick()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.subtitle)
                    }
                }
            }
    }
}

struct KeyboardDownButton: ViewModifier {
    
    let onClick: () -> Void
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button {
                        onClick()
                    } label: {
                        HStack{
                            Text("완료")
                            Image(systemName: "chevron.down")
                        }
                        .frame(width: 600)
                    }
                }
            }
    }
}

struct RoundBorder: ViewModifier {
    
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let borderColor: Color
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: lineWidth)
            )
    }
}

struct AdaptsToKeyboard: ViewModifier {
    @State var currentHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.currentHeight)
                .onAppear(perform: {
                    NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillShowNotification)
                        .merge(with: NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillChangeFrameNotification))
                        .compactMap { notification in
                            withAnimation(.easeOut(duration: 0.16)) {
                                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                            }
                    }
                    .map { rect in
                        rect.height - geometry.safeAreaInsets.bottom
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
                    
                    NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillHideNotification)
                        .compactMap { notification in
                            CGFloat.zero
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
                })
        }
    }
}

struct SingleLineTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, .moreLarge)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(.white)
            .roundBorder(cornerRadius: .small, lineWidth: 1, borderColor: .lightGray)
    }
}

struct MultiLineTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.moreLarge)
            .frame(maxWidth: .infinity)
            .lineLimit(10...)
            .background(.white)
            .roundBorder(cornerRadius: .small, lineWidth: 1, borderColor: .lightGray)
    }
}

struct ThreeLineTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.moreLarge)
            .frame(maxWidth: .infinity)
            .lineLimit(3...)
            .background(.white)
            .roundBorder(cornerRadius: .small, lineWidth: 1, borderColor: .lightGray)
    }
}

struct CustomMenuStyle: MenuStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .foregroundColor(.red)
            .border(Color.red)
    }
}
