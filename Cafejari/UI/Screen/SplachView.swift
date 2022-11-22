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
                    // 스플래쉬 끝난시점에서, 앱 시동이 끝나있다면
                    if coreState.isAppInitiated {
                        // 로그인 상태라면
                        if coreState.isLogedIn {
                            // 앱 권한 체크가 되어있는지 확인
                            if !coreState.isPermissionCheckFinished() {
                                coreState.navigate(Screen.PermissionRequest.route)
                            } else {
                                coreState.isPermissionChecked = true
                                coreState.clearStack()
                            }
                        } else {
                            // 로그인 안됐으면 로그인 화면으로
                            coreState.navigate(Screen.Login.route)
                        }
                    }
                    coreState.isSplashFinished = true
                }
            }
            if coreState.isSplashFinished {
                FullScreenLoadingView(loading: $coreState.isAppInitiated, text: "초기 설정중...")
            }
        }
    }
}
