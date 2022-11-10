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
    
    @State private var isProfileDetailExpanded = false
    @State private var selectedEventTabIndex = 0
    
    var body: some View {
        
        VStack(spacing: 0) {
            HStack {
                Text("카페자리와 함께한지 \(userViewModel.time.getPassingDayFrom(timeString: coreState.user.dateJoined))일째에요!")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(.gray)
            
            ScrollView{
                
                LazyVStack{
                    HStack {
                        ZStack(alignment: .topTrailing) {
                            RoundProfileImage(90)
                            VStack {
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.gray)
                                    .font(.body.bold())
                            }
                            .padding(5)
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                        }
                        .onTapGesture {
                            coreState.navigate(Screen.ProfileEdit.route)
                        }
                        
                        HStack {
                            VStack(alignment: .leading){
                                HStack{
                                    Image(systemName: "star.circle.fill")
                                    Text("\(coreState.user.grade)")
                                    Text("  \(coreState.user.nickname)")
                                }
                                if isProfileDetailExpanded {
                                    HStack{
                                        Image(systemName: "phone.fill")
                                        Text("010\(coreState.user.phoneNumber)")
                                    }.accentColor(.gray)
                                    HStack{
                                        Image(systemName: "envelope.fill")
                                        Text("sampleemail@google.com")
                                    }.accentColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            if(isProfileDetailExpanded){
                                Image(systemName: "chevron.up")
                            }else{
                                Image(systemName: "chevron.down")
                            }
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isProfileDetailExpanded.toggle()
                            }
                        }
                    }
                    .padding(.trailing, 15)
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    
                    HStack{
                        Text("모은 포인트")
                        HorizontalSpacer(15)
                        Text("\(coreState.user.point)P")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(15)
                    .frame(height: 56)
                    .background(Color.gray)
                    
                    HStack{
                        Text("내 마스터 활동 보러가기")
                            .font(.body.bold())
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .frame(height: 56)
                    .background(Color.gray)
                    .onTapGesture {
                        coreState.navigate(Screen.MasterDetail.route)
                    }
                    
                    VerticalSpacer(20)
                
                    ZStack {
                        if !informationViewModel.events.isEmpty {
                            TabView(selection: $selectedEventTabIndex) {
                                ForEach(Array(informationViewModel.events.enumerated()), id: \.offset) { index, event in
                                    CachedAsyncImage(
                                        url: URL(string: event.image),
                                        content: { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
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
                            .frame(height: 120)
                            
                            
                            VStack {
                                Text("\(selectedEventTabIndex + 1) / \(informationViewModel.events.count)")
                                    .foregroundColor(.white)
                                    .font(.callout)
                                    .padding(8)
                                    .background(.black.opacity(0.5))
                                    .cornerRadius(20)
                                    .frame(height: 24)
                                    .padding(15)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        } else {
                            Text("진행중인 이벤트가 없어요")
                                .frame(height: 120)
                        }
                    }
                    
                    VerticalSpacer(20)
                    
                    VStack(alignment: .leading, spacing: 40) {
                        VStack(alignment: .leading) {
                            Text("안내")
                                .font(.title3.bold())
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
                        VStack(alignment: .leading) {
                            Text("채널")
                                .font(.title3.bold())
                            LinkRow(text: "카페자리 인스타 구경하러가기") {
                                openURL(URL(string: userViewModel.httpRoute.insta())!)
                            }
                            LinkRow(text: "카페자리 블로그 구경하러가기") {
                                openURL(URL(string: userViewModel.httpRoute.blog())!)
                            }
                        }
                        VStack(alignment: .leading) {
                            Text("약관 및 처리방침")
                                .font(.title3.bold())
                            LinkRow(text: "개인정보 처리방침") {
                                openURL(URL(string: userViewModel.httpRoute.privacyPolicy())!)
                            }
                            LinkRow(text: "위치정보기반 서비스 이용약관") {
                                openURL(URL(string: userViewModel.httpRoute.tos())!)
                            }
                        }
                        HStack {
                            Text("1:1 문의")
                                .font(.title3.bold())
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .onTapGesture {
                            coreState.navigate(Screen.Inquiry.route)
                        }
                        Text("로그아웃")
                            .foregroundColor(.gray)
                            .font(.callout)
                            .underline()
                            .onTapGesture {
                                Task {
                                    await userViewModel.logout(coreState: coreState)
                                }
                            }
                        VerticalSpacer(50)
                    }
                }
                .padding(.horizontal, 15)
            }
            .scrollIndicators(.hidden)
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
                .foregroundColor(.gray)
                .font(.callout)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding(.vertical, 5)
        .onTapGesture {
            onTap()
        }
    }
}


extension Text {
    func dayOfWeek() -> some View {
        self.frame(maxWidth: .infinity)
            .padding(.top, 1)
            .lineLimit(1)
    }
}
