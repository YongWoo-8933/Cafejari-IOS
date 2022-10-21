//
//  MasterMapView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI

struct MasterMapView: View {
    @EnvironmentObject var master: Master
    @EnvironmentObject var coreState: CoreState
    
    @State private var selectedCafeFloorIndex = 0
    @State private var isBottomSheetOpened = false
    
    var body: some View {
        
        VStack{
            Text("마스터맵")
            
            Button{
                isBottomSheetOpened = true
            }label: {
                Image("crowded_marker_2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
            }
        }
        .sheet(isPresented: $isBottomSheetOpened){
            VStack{
                HStack{
                    Image("crowded_marker_1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 25)
                    Text("투썸플레이스 신촌점")
                        .font(.title3)
                    Spacer()
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 30)
                
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
                
                Button{
                    coreState.tapToMasterMap()
                    coreState.navigate(Screen.MasterRoom.route)
                    isBottomSheetOpened = false
                }label: {
                    HStack{
                        VStack(alignment: .leading) {
                            Text("마스터 등록 가능")
                                .foregroundColor(.green)
                            Text("( 활동중인 마스터 없음 )")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.callout.weight(.bold))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 100)
                }
            }
            .presentationDetents([.fraction(0.3)])
        }
    }
}

//struct MasterMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MasterMapView()
//    }
//}
