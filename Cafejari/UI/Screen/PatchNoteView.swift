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
        Update(order: 3, releaseVersionCode: 0, majorVersionCode: 0, minorVersionCode: 3, date: "22.11.30", content: "광고 배치 완료, 업데이트 대화상자 추가, 내 랭킹 확인하기 기능 추가, 버그수정"),
        Update(order: 4, releaseVersionCode: 1, majorVersionCode: 0, minorVersionCode: 0, date: "22.12.09", content: "정식출시, 버그수정, 회원탈퇴기능, 내 랭킹 확인 기능추가"),
        Update(order: 5, releaseVersionCode: 1, majorVersionCode: 0, minorVersionCode: 1, date: "22.12.10", content: "광고를 보지 않은 마스터 추천에도 포인트를 획득했다고 표기되는 오류 수정"),
        Update(order: 6, releaseVersionCode: 1, majorVersionCode: 0, minorVersionCode: 2, date: "22.12.18", content: "온보딩 다이얼로그 추가"),
        Update(order: 7, releaseVersionCode: 1, majorVersionCode: 0, minorVersionCode: 3, date: "22.12.21", content: "신규지역 추가 - 혜화, 건대입구"),
        Update(order: 8, releaseVersionCode: 1, majorVersionCode: 1, minorVersionCode: 0, date: "22.12.26", content: "카페 홍보문구 추가"),
        Update(order: 9, releaseVersionCode: 1, majorVersionCode: 1, minorVersionCode: 1, date: "23.01.06", content: "카페 정보를 못불러오던 일시적 오류 수정, 카페 홍보란 무한로딩 오류 수정"),
        Update(order: 10, releaseVersionCode: 1, majorVersionCode: 1, minorVersionCode: 2, date: "23.01.08", content: "카페 정보 로딩속도 개선"),
    ]
}
