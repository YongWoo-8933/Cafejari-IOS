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
            NavigationTitle(
                title: "업데이트 소식",
                leadingIconSystemName: "chevron.backward",
                onLeadingIconClick: {
                    coreState.popUp()
                }
            )
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Update.histories.reversed(), id: \.order) { update in
                        VStack(alignment: .leading, spacing: .medium) {
                            Text(update.date)
                                .font(.body)
                                .foregroundColor(.gray)
                            HStack(spacing: 0) {
                                Text("[ver \(update.releaseVersionCode).\(update.majorVersionCode).\(update.minorVersionCode)] 업데이트 내용을 알려드려요")
                                    .font(.headline.bold())
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
        Update(order: 0, releaseVersionCode: 0, majorVersionCode: 0, minorVersionCode: 0, date: "22.11-22", content: "아이폰 카페자리 앱 알파버전 출시"),
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
        Update(order: 11, releaseVersionCode: 1, majorVersionCode: 2, minorVersionCode: 2, date: "23.01.26", content: "UI개선(구글지도 > 네이버지도), 영업시간 정보 추가, 콘센트 정보 추가, 화장실 정보 추가, 제휴카페 보기 기능 추가, 팝업광고 추가, 이벤트 중인 카페 정리, 웹뷰 추가"),
        Update(order: 12, releaseVersionCode: 1, majorVersionCode: 2, minorVersionCode: 3, date: "23.02.03", content: "신규지역 추가: 흑석, 마커 새로고침 후 잠시 맵터치가 안되던 에러 개선"),
        Update(order: 13, releaseVersionCode: 1, majorVersionCode: 3, minorVersionCode: 0, date: "23.02.14", content: "카페정보 로딩속도 개선, 거리제한 완화, 포인트 지급내역 확인 화면 추가, 할인중인 카페 거리순 정렬, 신규지역 추가 - 노량진/안암/신림/서울대입구/왕십리/외대앞/회기"),
        Update(order: 14, releaseVersionCode: 1, majorVersionCode: 3, minorVersionCode: 1, date: "23.02.19", content: "메인 화면 버튼 배치 변경, 일부 ui개선"),
        Update(order: 15, releaseVersionCode: 1, majorVersionCode: 4, minorVersionCode: 0, date: "23.02.26", content: "카페 검색 기능 추가, 추천인 이벤트 추가, 카페 정보 제보 기능 추가, 자동 종료된 마스터 활동 광고 보기 추가, 거리제한 완화, 애니메이션 및 성능개선"),
    ]
}
