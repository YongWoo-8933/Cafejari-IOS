//
//  SplachView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/16.
//

import SwiftUI

struct SplachView: View {
    
    @State private var isLightOn = false
    
    var body: some View {
        ZStack{
            VStack{
                Image( isLightOn ? "splash_light_on" : "splash_light_off" )
                    .resizable()
                    .scaledToFit()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    isLightOn = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1){
                    isLightOn = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4){
                    isLightOn = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                    isLightOn = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1){
                    isLightOn = true
                }
            }
        }
    }
}

struct SplachView_Previews: PreviewProvider {
    static var previews: some View {
        SplachView()
    }
}
