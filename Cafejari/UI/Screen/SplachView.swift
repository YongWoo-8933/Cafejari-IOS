//
//  SplachView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/16.
//

import SwiftUI

struct SplachView: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var userViewModel: UserViewModel
    
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
                Task {
                    await userViewModel.appInit(coreState: coreState)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    isLightOn = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                    isLightOn = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    isLightOn = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isLightOn = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                    isLightOn = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                    if coreState.isAppInitiated {
                        if coreState.isLogedIn {
                            if coreState.user.authorization {
                                coreState.clearStack()
                            } else {
                                coreState.navigate(Screen.Auth.route)
                            }
                        } else {
                            coreState.navigate(Screen.Login.route)
                        }
                    }
                    withAnimation {
                        coreState.isSplashFinished = true
                    }
                }
            }
            if coreState.isSplashFinished {
                FullScreenLoadingView(loading: $coreState.isAppInitiated, text: "초기 설정중...")
            }
        }
    }
}
