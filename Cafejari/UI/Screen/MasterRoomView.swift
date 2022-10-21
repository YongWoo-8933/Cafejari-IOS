//
//  MasterRoomView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI

struct MasterRoomView: View {
    
    @EnvironmentObject var master: Master
    @EnvironmentObject var coreState: CoreState
    
    @State private var crowdedSliderValue = 100.0
    @State private var sliderColor = Color.green
    
    var body: some View {
        ScrollView{
            LazyVStack{
                ZStack{
                    Image("cafe_picture_default")
                        .resizable()
                        .scaledToFit()
                    VStack{
                        Text("여기는 꿀팁이 들어올 자리 블라블라 두줄 세줄 계속 드러갈 것이여\n")
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        Text("-카페자리우녕자")
                            .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                    }
                    .foregroundColor(.white)
                    .padding(30)
                    .background(.black.opacity(0.6))
                    .cornerRadius(10)
                    .padding(30)
                    
                }
                .frame(maxWidth: .infinity)
                
                HStack{
                    Text("스타벅스 뭐시기 신촌뭐시기점")
                    Spacer()
                    Button{
                        
                    }label: {
                        Image(systemName: "scope")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                
                if(!master.isMasterActivated){
                    Text("초기 혼잡도 값을 지정해주세요")
                        .foregroundColor(.gray)
                    Text("(현재 이곳의 마스터가 아닙니다)")
                        .foregroundColor(.gray)
                }else{
                    Image("cafe_picture_default")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .cornerRadius(20)
                }
                
                HStack{
                    Image("crowded_marker_0")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .onTapGesture {
                            crowdedSliderValue = 0.0
                        }
                    Spacer()
                    Image("crowded_marker_1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .onTapGesture {
                            crowdedSliderValue = 100.0
                        }
                    Spacer()
                    Image("crowded_marker_2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .onTapGesture {
                            crowdedSliderValue = 200.0
                        }
                    Spacer()
                    Image("crowded_marker_3")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .onTapGesture {
                            crowdedSliderValue = 300.0
                        }
                    Spacer()
                    Image("crowded_marker_4")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .onTapGesture {
                            crowdedSliderValue = 400.0
                        }
                }
                
                Slider(value: $crowdedSliderValue, in: 0...400, step: 1){
                    Text("Speed")
                } onEditingChanged: { editing in
                    if !editing {
                        if crowdedSliderValue < 50.0 {
                            crowdedSliderValue = 0.0
                            sliderColor = Color.blue
                        } else if crowdedSliderValue < 150.0 {
                            crowdedSliderValue = 100.0
                            sliderColor = Color.green
                        } else if crowdedSliderValue < 250.0 {
                            crowdedSliderValue = 200.0
                            sliderColor = Color.yellow
                        } else if crowdedSliderValue < 350.0 {
                            crowdedSliderValue = 300.0
                            sliderColor = Color.orange
                        } else {
                            crowdedSliderValue = 400.0
                            sliderColor = Color.red
                        }
                    }
                }
                .onChange(of: crowdedSliderValue){ newValue in
                    if newValue < 100.0 {
                        sliderColor = Color.blue
                    } else if newValue < 200.0 {
                        sliderColor = Color.green
                    } else if newValue < 300.0 {
                        sliderColor = Color.yellow
                    } else if newValue < 400.0 {
                        sliderColor = Color.orange
                    } else {
                        sliderColor = Color.red
                    }
                }
                .accentColor(sliderColor)
                .padding(.horizontal, 8)
                
                HStack{
                    Text("한적")
                    Spacer()
                    Text("여유")
                    Spacer()
                    Text("보통")
                    Spacer()
                    Text("혼잡")
                    Spacer()
                    Text("만석")
                }
                
                Button{
                    if master.isMasterActivated {
                        // crowded change logic
                    }else{
                        master.activateMaster(cafeId: 0)
                    }
                }label: {
                    if master.isMasterActivated {
                        Text("혼잡도 변경")
                            .padding(10)
                            .background(.brown)
                            .cornerRadius(10)
                            .frame(width: 100)
                    }else{
                        Text("마스터 등록")
                            .padding(10)
                            .background(.brown)
                            .cornerRadius(10)
                            .frame(width: 100)
                    }
                }
                    
                Text("이 아래로 각종 로그들")
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                Button{
                    if(master.isMasterActivated){
                        coreState.tapToHome()
                    }
                    coreState.clearStack()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .font(.callout.weight(.semibold))
                        master.isMasterActivated ? Text("홈") : Text("마스터지도")
                    }
                }
            }
            ToolbarItem(placement: .principal) {
                Text("마스터룸")
                    .font(.title2)
                    .fontWeight(.black)
                    .padding(.vertical, 15)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Toggle("", isOn: $master.isMasterActivated)
                    .toggleStyle(.switch)
            }
        }
    }
}

struct MasterRoomView_Previews: PreviewProvider {
    static var previews: some View {
        MasterRoomView()
    }
}
