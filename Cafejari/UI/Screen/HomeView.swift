//
//  ContentView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI
import CoreData
import CachedAsyncImage

struct HomeView: View {
    
    @Environment(\.openURL) private var openURL
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var master: Master
    @EnvironmentObject private var informationViewModel: InformationViewModel
    
    @State private var isMenuOpened = false
    @State private var selectedEventTabIndex = 0
    @State private var selectedInformationCategoryId: UUID? = nil
    @State private var selectedItemCategoryId: UUID? = nil
    
    @State private var tempText: String = "ㅇ"
    @State private var savedToken: String = ""
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 25)!]
    }
    
    var body: some View {
        ZStack{ GeometryReader { geo in
            NavigationStack(path: $coreState.navigationPath) {
                TabView(selection: $coreState.selectedBottomBarItem){
                    UserMapView()
                    .tabItem{
                        Label(
                            BottomTab.UserMap.name,
                            systemImage: BottomTab.UserMap.SFImage
                        )
                    }
                    .tag(BottomTab.UserMap.name)
                    
                    ScrollView{
                        ZStack {
                            TabView(selection: $selectedEventTabIndex) {
                                Image("banner_default")
                                    .resizable()
                                    .scaledToFit()
                                    .tag(0)
                                    .onTapGesture {
                                        coreState.navigate(Screen.GuideGrid.route)
                                    }
                                ForEach(
                                    Array(informationViewModel.events.enumerated()), id: \.offset
                                ) { index, event in
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
                                    .tag(index + 1)
                                }
                            }
                            .tabViewStyle(.page)
                            .indexViewStyle(.page(backgroundDisplayMode: .never))
                            .frame(height: 140)
                            
                            VStack{
                                Spacer()
                                HStack{
                                    Spacer()
                                    NavigationLink{
                                        PromotionView()
                                    } label: {
                                        Text("\(selectedEventTabIndex + 1) / \(informationViewModel.events.count + 1) 모두보기")
                                            .foregroundColor(.white)
                                            .padding(9)
                                            .background(.black.opacity(0.5))
                                            .cornerRadius(15)
                                            .frame(height: 30)
                                    }
                                    .padding(15)
                                }
                            }
                        }
                        
                        LazyVStack(alignment: .leading){
                            HStack {
                                Image("stamp_icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                Text("오늘의 TIP")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding([.horizontal, .top], 15)

                            Text(informationViewModel.randomTip.saying)
                                .font(.custom("나눔손글씨 다행체", size: 21))
                                .padding([.horizontal, .bottom], 15)
                            
                            LazyVGrid(
                                columns: GridItem(.flexible()).setGridColumn(columns: 2),
                                spacing: 10
                            ) {
                                Button{
                                    coreState.tapToUserMap()
                                }label: {
                                    VStack{
                                        Image("user_map_btn")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(10)
                                            .frame(height: geo.size.width/3)
                                        Text("내 주변 카페")
                                    }
                                    .frame(height: 160)
                                }
                                Button{
                                    coreState.tapToMasterMap()
                                } label: {
                                    VStack{
                                        Image("master_map_btn")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: geo.size.width/3)
                                        Text("카페 마스터 하러가기")
                                    }
                                    .frame(height: 200)
                                }
                            }
                            .frame(maxHeight: 250)
                            
                            VStack(alignment: .leading) {
                                Text("서비스 지역 안내")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.semibold)
                                Divider()
                                HStack{
                                    Text("신촌")
                                    Text("광운대")
                                }
                                Text("현재 카페자리는 뭐시기 뭐시기")
                            }
                            .padding(15)
                            
                            VStack {
                                HStack(alignment: .bottom) {
                                    Text("포인트 상점")
                                        .font(.system(.title3, design: .rounded))
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Button {
                                        selectedItemCategoryId = nil
                                        coreState.navigate(Screen.Shop.route)
                                    } label: {
                                        Text("전체보기 >")
                                            .foregroundColor(.gray)
                                            .font(.system(.caption, design: .rounded))
                                    }
                                }
                                Divider()
                                
                                LazyVGrid(
                                    columns: GridItem(.flexible()).setGridColumn(columns: 3),
                                    spacing: 10
                                ) {
                                    ForEach(ItemCategory.itemCategories) { itemCategory in
                                        Button {
                                            selectedItemCategoryId = itemCategory.id
                                            coreState.navigate(Screen.Shop.route)
                                        } label: {
                                            VStack{
                                                Image(itemCategory.image)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .padding(20)
                                                Text(itemCategory.name)
                                            }
                                            .frame(height: geo.size.width / 3)
                                        }
                                        .frame(height: 120)
                                    }
                                }
                                
                                LazyVGrid(
                                    columns: GridItem(.flexible()).setGridColumn(columns: 4),
                                    spacing: 10
                                ) {
                                    ForEach(InformationCategory.informationCategories){ informationCategory in
                                        Button{
                                            if(informationCategory.name == "가이드"){
                                                coreState.navigate(Screen.GuideGrid.route)
                                            }else{
                                                coreState.navigate(Screen.Information.route)
                                            }
                                        } label:{
                                            VStack{
                                                Image(informationCategory.image)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .padding(20)
                                                Text(informationCategory.name)
                                            }
                                            .frame(height: geo.size.width / 3)
                                        }
                                        .frame(height: 120)
                                    }
                                }
                            }
                            .padding(15)
                        }
                    }
                    .scrollIndicators(.never)
                    .tabItem{
                        Label(
                            BottomTab.Home.name,
                            systemImage: BottomTab.Home.SFImage
                        )
                    }
                    .tag(BottomTab.Home.name)
                    
                    MasterMapView()
                    .tabItem{
                        if(master.isMasterActivated){
                            Label(
                                "마스터룸",
                                systemImage: BottomTab.MasterMap.SFImage
                            )
                        }else{
                            Label(
                                BottomTab.MasterMap.name,
                                systemImage: BottomTab.MasterMap.SFImage
                            )
                        }
                    }
                    .tag(BottomTab.MasterMap.name)
                }
                .onChange(of: coreState.selectedBottomBarItem) { newTap in
                    if(newTap == BottomTab.MasterMap.name && master.isMasterActivated){
                        coreState.navigate(Screen.MasterRoom.route)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("홈")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            coreState.navigate(Screen.Profile.route)
                        } label: {
                            Image(systemName: "person.crop.circle")
                                .font(.callout.weight(.bold))
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Image("home_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                            .padding(10)
                    }
                    ToolbarItem(placement: .navigationBarLeading){
                        Button{
                            isMenuOpened = true
                            informationViewModel.deleteSavedRefreshToken()
                        }label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.callout.weight(.bold))
                        }
                    }
                }
                .navigationBarHidden(coreState.selectedBottomBarItem != BottomTab.Home.name)
                .navigationDestination(for: String.self) { value in
                    switch value {
                    case Screen.Profile.route:
                        ProfileView()
                    case Screen.Shop.route:
                        ShopView(selectedCategoryId: selectedItemCategoryId)
                    case Screen.GuideGrid.route:
                        GuideGridView()
                    case Screen.Information.route:
                        InformationView()
                    case Screen.Login.route:
                        LoginView()
                    case Screen.Auth.route:
                        AuthView()
                    case Screen.MasterRoom.route:
                        MasterRoomView()
                    default:
                        EmptyView()
                    }
                }
                .accentColor(.black)
            }
            EmptyView()
                .background(.black.opacity(0.4))
                .opacity(isMenuOpened ? 1 : 0)
                .animation(.easeInOut, value: isMenuOpened)
                .onTapGesture {
                    isMenuOpened.toggle()
                }
            SideMenu(isSidebarVisible: $isMenuOpened)
        }}
        .task {
            if coreState.isAppInitiated {
                if !coreState.isLogedIn || !coreState.user.authorization {
                    coreState.navigate(Screen.Login.route)
                }
            }
            await informationViewModel.getEvents()
            await informationViewModel.getRandomTip()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
