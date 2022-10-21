//
//  UserMapView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI
import UIKit

struct UserMapView: View {
    
    @State private var isBottomSheetOpened = false
    @State private var selectedCafeFloorIndex = 0
    @State private var currentCrowded = 1.0
    
    init() {
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
    
    var body: some View {
        ZStack{
            GoogleMapView()
                .ignoresSafeArea(edges: .top)
        }
        .sheet(isPresented: $isBottomSheetOpened){
            ScrollView{
                LazyVStack{
                    HStack{
                        Image("crowded_marker_1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 25)
                        Text("투썸플레이스 신촌점")
                            .font(.title3)
                        Spacer()
                        Button{
                            
                        }label: {
                            Image(systemName: "info.circle")
                                .font(.callout.weight(.bold))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 30)
                    
                    ScrollView(.horizontal){
                        LazyHStack{
                            ForEach(0 ..< 5){ _ in
                                Image("cafe_picture_default")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 180)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    .scrollIndicators(.hidden)
                    
                    HStack{
                        Button{
                            
                        }label: {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.gray)
                        }
                        Text("서울턱별시 서대문구 연세로 1-1")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                    
                    HStack{
                        Button{
                            
                        }label: {
                            Image(systemName: "phone")
                                .foregroundColor(.gray)
                        }
                        Text("010-1234-5678")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                    
                    HStack{
                        Button{
                            
                        }label: {
                            Image(systemName: "link")
                                .foregroundColor(.gray)
                        }
                        Text("https://cafejari.software/admin/")
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                    
                    HStack(spacing: 24){
                        Button{
                            selectedCafeFloorIndex = 0
                        }label: {
                            ZStack{
                                FloorTabShape0()
                                    .stroke(style: StrokeStyle(lineWidth: 15.0, lineCap: .round))
                                    .foregroundColor(selectedCafeFloorIndex == 0 ? Color.white : Color.gray)
                                    .frame(width: 40, height: 12)
                                FloorTabShape1()
                                    .stroke(style: StrokeStyle(lineWidth: 15.0, lineCap: .round))
                                    .foregroundColor(selectedCafeFloorIndex == 0 ? Color.white : Color.gray)
                                    .frame(width: 40, height: 12)
                                Text("1층")
                                    .foregroundColor(.black)
                            }
                        }
                        Button{
                            selectedCafeFloorIndex = 1
                        }label: {
                            ZStack{
                                FloorTabShape0()
                                    .stroke(style: StrokeStyle(lineWidth: 15.0, lineCap: .round))
                                    .foregroundColor(selectedCafeFloorIndex == 1 ? Color.white : Color.gray)
                                    .frame(width: 40, height: 12)
                                FloorTabShape1()
                                    .stroke(style: StrokeStyle(lineWidth: 15.0, lineCap: .round))
                                    .foregroundColor(selectedCafeFloorIndex == 1 ? Color.white : Color.gray)
                                    .frame(width: 40, height: 12)
                                Text("2층")
                                    .foregroundColor(.black)
                            }
                        }
                        Button{
                            selectedCafeFloorIndex = 2
                        }label: {
                            ZStack{
                                FloorTabShape0()
                                    .stroke(style: StrokeStyle(lineWidth: 15.0, lineCap: .round))
                                    .foregroundColor(selectedCafeFloorIndex == 2 ? Color.white : Color.gray)
                                    .frame(width: 40, height: 12)
                                FloorTabShape1()
                                    .stroke(style: StrokeStyle(lineWidth: 15.0, lineCap: .round))
                                    .foregroundColor(selectedCafeFloorIndex == 2 ? Color.white : Color.gray)
                                    .frame(width: 40, height: 12)
                                Text("3층")
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                    
                    TabView(selection: $selectedCafeFloorIndex){
                        ForEach(0..<3){ index in
                            VStack{
                                Text("여유")
                                    .foregroundColor(.green)
                                Text("(\(index)분전)")
                                    .foregroundColor(.gray)
                                HStack{
                                    Image("crowded_marker_0")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30)
                                    ForEach(1..<5){ marker_index in
                                        Spacer()
                                        Image("crowded_marker_\(marker_index)")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30)
                                    }
                                }
                                ZStack{
                                    HStack{
                                        HStack{
                                            
                                        }
                                        .frame(width: 100, height: 6)
                                        .background(.blue)
                                        .cornerRadius(3)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 6)
                                    .background(.gray)
                                    .cornerRadius(3)
                                }
                            }
                            .tabItem{
                                Text("\(index + 1)층")
                            }
                            .tag(index)
                        }
                    }
                    .frame(height: 200)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    HStack{
                        Text("한적")
                        Spacer()
                        Text("만석")
                    }
                    
                    HStack{
                        Image(systemName: "star.circle.fill")
                        Text("1")
                        Text("  닉네임")
                        Button{
                            
                        }label: {
                            Image(systemName: "hand.thumbsup")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .presentationDetents([.fraction(0.4), .large])
        }
    }
}

struct UserMapView_Previews: PreviewProvider {
    static var previews: some View {
        UserMapView()
    }
}
