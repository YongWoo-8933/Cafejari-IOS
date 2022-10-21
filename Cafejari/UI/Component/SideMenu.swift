//
//  SideMenu.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/11.
//

import SwiftUI

struct SideMenu: View {
    @Binding var isSidebarVisible: Bool
    
    var sideBarWidth = UIScreen.main.bounds.size.width * 0.7
    var bgColor: Color =
    Color(.init(
        red: 52 / 255,
        green: 70 / 255,
        blue: 182 / 255,
        alpha: 1))
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(.black.opacity(0.6))
            .opacity(isSidebarVisible ? 1 : 0)
            .animation(.easeInOut.delay(0.1), value: isSidebarVisible)
            .onTapGesture {
                isSidebarVisible.toggle()
            }
            content
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    var content: some View {
        HStack(alignment: .top) {
            ZStack(alignment: .top) {
                bgColor
            }
            .frame(width: sideBarWidth)
            .offset(x: isSidebarVisible ? 0 : -sideBarWidth)
            .animation(.default, value: isSidebarVisible)
            
            Spacer()
        }
    }
}
