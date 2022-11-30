//
//  ProfileView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI
import CachedAsyncImage

struct ProfileView: View {
    
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject var coreState: CoreState
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var informationViewModel: InformationViewModel
    
    @State private var selectedEventTabIndex = 0
    @State private var isLogoutDialogOpened = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Text("카페자리와 함께한지 ")
                        .foregroundColor(.white)
                    +
                    Text("\(userViewModel.time.getPassingDayFrom(timeString: coreState.user.dateJoined))일 째")
                        .font(.body.bold())
                        .foregroundColor(.white)
                    +
                    Text(" 에요!")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.large)
                .background(Color.primary)
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        HStack(spacing: .moreLarge) {
                            ZStack(alignment: .topTrailing) {
                                RoundProfileImage(image: coreState.user.image, size: 100)
                                VStack {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.primary)
                                        .font(.headline.bold())
                                }
                                .frame(width: 28, height: 28)
                                .background(.white)
                                .clipShape(Circle())
                                .roundBorder(cornerRadius: 14, lineWidth: 1.5, borderColor: .primary)
                            }
                            .onTapGesture {
                                coreState.navigate(Screen.ProfileEdit.route)
                            }
                            
                            VStack(alignment: .leading, spacing: .medium) {
                                HStack(spacing: .medium) {
                                    Text(coreState.user.nickname)
                                        .font(.headline.bold())
                                    HStack(spacing: .small) {
                                        Image(systemName: "hand.thumbsup.fill")
                                            .font(.caption.bold())
                                            .foregroundColor(.white)
                                        Text("\(coreState.user.grade)")
                                            .font(.caption.bold())
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, .large)
                                    .frame(height: 24)
                                    .background(Color.primary)
                                    .cornerRadius(12)
                                }
                                Text(coreState.user.email)
                                    .font(.body.weight(.medium))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VerticalSpacer(.moreLarge)
                        
                        HStack(spacing: .medium) {
                            Image(systemName: "p.circle.fill")
                                .font(.title.bold())
                                .foregroundColor(.primary)
                            Text("모은 포인트")
                                .font(.body.weight(.medium))
                                .foregroundColor(.primary)
                            Text("\(coreState.user.point)P")
                                .font(.body.bold())
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, .large)
                        .frame(height: 40)
                        .background(Color.background)
                        .cornerRadius(.medium)
                        
                        VerticalSpacer(.medium)
                        
                        HStack(spacing: .medium) {
                            Image(systemName: "mustache.fill")
                                .font(.headline.bold())
                                .foregroundColor(.primary)
                            Text("내 마스터 활동 보러가기")
                                .font(.body.bold())
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.forward")
                                .foregroundColor(.primary)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, .large)
                        .frame(height: 40)
                        .background(Color.background)
                        .cornerRadius(.medium)
                        .onTapGesture {
                            coreState.navigate(Screen.MasterDetail.route)
                        }
                        
                        VerticalSpacer(.moreLarge)
                        
                        ZStack(alignment: .bottomTrailing) {
                            if !informationViewModel.events.isEmpty {
                                TabView(selection: $selectedEventTabIndex) {
                                    ForEach(Array(informationViewModel.events.enumerated()), id: \.offset) { index, event in
                                        CachedAsyncImage(
                                            url: URL(string: event.image),
                                            content: { image in
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(maxWidth: .infinity)
                                                    .cornerRadius(.medium)
                                                    .onTapGesture {
                                                        openURL(URL(string: event.url)!)
                                                    }
                                            },
                                            placeholder: {
                                                ProgressView()
                                            }
                                        )
                                        .tag(index)
                                    }
                                }
                                .tabViewStyle(.page)
                                .indexViewStyle(.page(backgroundDisplayMode: .never))
                                
                                VStack {
                                    Text("\(selectedEventTabIndex + 1) / \(informationViewModel.events.count)")
                                        .foregroundColor(.white)
                                        .font(.caption.bold())
                                        .padding(.medium)
                                        .background(.black.opacity(0.5))
                                        .cornerRadius(.moreLarge)
                                }
                                .padding(.large)
                            } else {
                                Text("진행중인 이벤트가 없어요")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 120)
                            }
                        }
                        .frame(height: 120)
                        
                        VerticalSpacer(36)
                        
                        VStack(alignment: .leading, spacing: 36) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("안내")
                                    .font(.headline.bold())
                                LinkRow(text: "FAQ") {
                                    coreState.navigate(Screen.FAQ.route)
                                }
                                LinkRow(text: "사용 가이드북 보기") {
                                    coreState.navigate(Screen.GuideGrid.route)
                                }
                                LinkRow(text: "공지 및 이벤트") {
                                    coreState.navigate(Screen.Promotion.route)
                                }
                                LinkRow(text: "업데이트 소식") {
                                    coreState.navigate(Screen.PatchNote.route)
                                }
                            }
                            VStack(alignment: .leading, spacing: 16) {
                                Text("채널")
                                    .font(.headline.bold())
                                LinkRow(text: "카페자리 인스타 구경하러가기") {
                                    openURL(URL(string: userViewModel.httpRoute.insta())!)
                                }
                                LinkRow(text: "카페자리 블로그 구경하러가기") {
                                    openURL(URL(string: userViewModel.httpRoute.blog())!)
                                }
                            }
                            VStack(alignment: .leading, spacing: 16) {
                                Text("약관 및 처리방침")
                                    .font(.headline.bold())
                                LinkRow(text: "개인정보 처리방침") {
                                    openURL(URL(string: userViewModel.httpRoute.privacyPolicy())!)
                                }
                                LinkRow(text: "위치정보기반 서비스 이용약관") {
                                    openURL(URL(string: userViewModel.httpRoute.tos())!)
                                }
                            }
                            HStack {
                                Text("1:1 문의")
                                    .font(.headline.bold())
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .font(.caption.bold())
                            }
                            .onTapGesture {
                                coreState.navigate(Screen.Inquiry.route)
                            }
                            Text("로그아웃")
                                .foregroundColor(.moreHeavyGray)
                                .font(.headline.weight(.medium))
                                .underline()
                                .onTapGesture {
                                    isLogoutDialogOpened = true
                                }
                        }
                        
                        VStack(spacing: .moreLarge) {
                            Divider()
                            
                            Text("ver \(Version.current.release).\(Version.current.major).\(Version.current.minor)")
                                .foregroundColor(.lightGray)
                        }
                        .padding(.vertical, .moreLarge)
                    }
                    .padding(.moreLarge)
                    .padding(.vertical, .medium)
                }
                .scrollIndicators(.hidden)
            }
            
            Dialog(
                isDialogVisible: $isLogoutDialogOpened,
                positiveButtonText: "더 볼래요",
                negativeButtonText: "로그아웃",
                onPositivebuttonClick: {},
                onNegativebuttonClick: {
                    Task {
                        await userViewModel.logout(coreState: coreState)
                        userViewModel.myWeekRanking = nil
                        userViewModel.myMonthRanking = nil
                        userViewModel.isMyWeekRankingVisible = false
                        userViewModel.isMyMonthRankingVisible = false
                    }
                },
                onDismiss: {}
            ) {
                Text("정말 로그아웃 하시겠습니까?\n")
                    .font(.headline.weight(.medium))
                +
                Text("*자동 로그인이 해제됩니다")
                    .foregroundColor(.moreHeavyGray)
                    .baselineOffset(-.medium)
            }
        }
        .task {
            await userViewModel.getUser(coreState: coreState)
            
            if informationViewModel.events.isEmpty {
                await informationViewModel.getEvents(coreState: coreState)
            }
        }
    }
}


struct LinkRow: View {
    
    let text: String
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
            Image(systemName: "chevron.forward")
                .font(.caption.bold())
        }
        .onTapGesture {
            onTap()
        }
    }
}
