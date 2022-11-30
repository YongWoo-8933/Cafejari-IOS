//
//  PatchNoteView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/05.
//

import SwiftUI

struct PatchNoteView: View {
    
    @EnvironmentObject private var coreState: CoreState
    
    @State private var selectedPatchVersionOrder: Int? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitle(title: "업데이트 소식", leadingIconSystemName: "chevron.backward") {
                coreState.popUp()
            }
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Update.histories.reversed(), id: \.order) { update in
                        VStack(alignment: .leading, spacing: .medium) {
                            Text(update.date)
                                .font(.headline)
                                .foregroundColor(.gray)
                            HStack(spacing: 0) {
                                Text("[ver \(update.releaseVersionCode).\(update.majorVersionCode).\(update.minorVersionCode)] 업데이트 내용을 알려드려요")
                                    .font(.subtitle.bold())
                                Spacer()
                                Image(systemName: selectedPatchVersionOrder == update.order ? "chevron.up" : "chevron.down")
                                    .font(.caption2.bold())
                            }
                            if selectedPatchVersionOrder == update.order {
                                VerticalSpacer(.medium)
                                Text(update.content)
                                    .foregroundColor(.moreHeavyGray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.moreLarge)
                        .onTapGesture {
                            if selectedPatchVersionOrder == update.order {
                                selectedPatchVersionOrder = nil
                            } else {
                                selectedPatchVersionOrder = update.order
                            }
                        }
                        Divider()
                    }
                }
                .animation(.easeInOut, value: selectedPatchVersionOrder)
            }
            .scrollIndicators(.never)
        }
        .navigationBarBackButtonHidden()
    }
}

struct Update {
    let order: Int
    let releaseVersionCode: Int
    let majorVersionCode: Int
    let minorVersionCode: Int
    let date: String
    let content: String
}

extension Update {
    static let histories = [
        Update(order: 0, releaseVersionCode: 0, majorVersionCode: 0, minorVersionCode: 0, date: "22.11.22", content: "아이폰 카페자리 앱 알파버전 출시"),
        Update(order: 1, releaseVersionCode: 0, majorVersionCode: 0, minorVersionCode: 1, date: "22.11.22", content: "앱 추적권한요청 삭제"),
        Update(order: 2, releaseVersionCode: 0, majorVersionCode: 0, minorVersionCode: 2, date: "22.11.24", content: "가이드 이미지 변경, 앱권한 문구 수정, 테스트 배너광고 실제 광고로 전환"),
        Update(order: 3, releaseVersionCode: 0, majorVersionCode: 0, minorVersionCode: 3, date: "22.11.30", content: "광고 배치 완료, 내 랭킹 확인하기 기능 추가, 버그수정")
    ]
}
