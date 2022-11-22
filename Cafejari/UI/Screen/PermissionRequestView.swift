//
//  PermissionRequestView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/21.
//

import SwiftUI

struct PermissionRequestView: View {
    
    @EnvironmentObject private var coreState: CoreState
    
    @State private var isLocationPermissionDiscriptionOpened = false
    @State private var isPushPermissionDiscriptionOpened = false
    @State private var isTrackingPermissionDiscriptionOpened = false
    @State private var isPhotoPermissionDiscriptionOpened = false
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitle(title: "앱 권한", leadingIconSystemName: "", onLeadingIconClick: {})
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    VerticalSpacer(.moreLarge)
                    
                    VStack(alignment: .leading, spacing: .small) {
                        Text("원활한 앱 사용을 위해 다음 권한이 필요합니다.\n")
                            .font(.headline)
                        Text("권고")
                            .font(.body.bold())
                            .foregroundColor(.moreHeavyGray)
                        +
                        Text("하는 권한의 경우, 허용하지 않으시면")
                            .foregroundColor(.moreHeavyGray)
                        Text("카페자리 ")
                            .foregroundColor(.moreHeavyGray)
                            .baselineOffset(2)
                        +
                        Text("핵심 컨텐츠 이용에 차질")
                            .font(.body.bold())
                            .foregroundColor(.moreHeavyGray)
                            .baselineOffset(2)
                        +
                        Text("이 있을 수 있습니다.")
                            .foregroundColor(.moreHeavyGray)
                            .baselineOffset(2)
                        Text("*모든 권한을 허용하는 것을 추천합니다")
                            .font(.caption)
                            .foregroundColor(.textPrimary)
                    }
                    
                    VerticalSpacer(40)
                    
                    VStack(alignment: .leading, spacing: .large) {
                        Text("권고")
                            .font(.headline.bold())
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, .medium)
                        
                        Divider()
                        
                        PermissionRow(
                            isDescriptionOpened: $isLocationPermissionDiscriptionOpened,
                            iconSystemName: "location",
                            text: "앱 사용중 기기 위치 탐색",
                            description: "혼잡도 정보를 공유할 때, 사용자가 해당 카페에 위치하는지 확인하는데 주로 사용됩니다. 또한, 지도에서 내 위치를 표시하려면 권한이 반드시 필요합니다. 따라서 허용하지 않으실 경우, 혼잡도 공유는 물론 지도에서 내 위치도 확인하실 수 없습니다."
                        )
                        
                        PermissionRow(
                            isDescriptionOpened: $isPushPermissionDiscriptionOpened,
                            iconSystemName: "bell",
                            text: "알림",
                            description: "혼잡도 정보를 공유하는 활동을 할때, 업데이트 주기 및 권한해제 등을 알림으로 알려드립니다. 허용하지 않으실 경우, 아무런 고지 없이 공유활동이 종료되어 사용에 불편함을 느끼실 수 있습니다. *마케팅 push 수신과 구별됨을 알려드립니다."
                        )
                    }
                    .frame(maxWidth: .infinity)
                    
                    VerticalSpacer(30)
                    
                    VStack(alignment: .leading, spacing: .large) {
                        Text("추천")
                            .font(.headline.bold())
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, .medium)
                        
                        Divider()
                        
                        PermissionRow(
                            isDescriptionOpened: $isTrackingPermissionDiscriptionOpened,
                            iconSystemName: "location.magnifyingglass",
                            text: "앱 추적",
                            description: "해당 권한은 앱 사용시 표기되는 광고가 사용자에게 맞춤 제공될 수 있도록 하는데에만 사용됩니다. 광고수익으로 유지되는 무료앱인만큼, 권한을 허용하셔서 앱을 운영하는데 도움을 주시면 감사드리겠습니다."
                        )
                        
                        PermissionRow(
                            isDescriptionOpened: $isPhotoPermissionDiscriptionOpened,
                            iconSystemName: "photo",
                            text: "저장소(이미지) 접근",
                            description: "해당 권한은 사용자의 프로필 사진 변경과 추후 업데이트될 카페사진 공유등을 위해 사진을 업로드할때 필요한 권한입니다. 허용하지 않으실 경우, 프로필 사진 변경이 불가합니다."
                        )
                    }
                    .frame(maxWidth: .infinity)
                    
                    VerticalSpacer(80)
                    
                    FilledCtaButton(text: "다음", backgroundColor: .primary) {
                        coreState.requestPermissions()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.moreLarge)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden()
    }
}

struct PermissionRow: View {
    
    @Binding var isDescriptionOpened: Bool
    
    let iconSystemName: String
    let text: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: .moreLarge) {
                Image(systemName: iconSystemName)
                    .font(.body)
                    .foregroundColor(.heavyGray)
                    .frame(width: 18)
                Text(text)
                    .font(.headline)
                    .foregroundColor(.heavyGray)
                Spacer()
                Image(systemName: "chevron.\(isDescriptionOpened ? "up" : "down")")
                    .font(.caption2)
                    .foregroundColor(.heavyGray)
            }
            .onTapGesture {
                isDescriptionOpened.toggle()
            }
            if isDescriptionOpened {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.heavyGray)
                    .padding(.vertical, .large)
                    .padding(.horizontal, .medium)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, .medium)
        .animation(.easeInOut, value: isDescriptionOpened)
    }
}
