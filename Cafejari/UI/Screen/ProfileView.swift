//
//  ProfileView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var coreState: CoreState
    
    @State private var isProfileDetailExpanded = false
    @State private var dateHolder = DateHolder()
    
    var body: some View {
        VStack {
            ScrollView{
                LazyVStack{
                    Button {
                        isProfileDetailExpanded = !isProfileDetailExpanded
                    } label: {
                        HStack{
                            AsyncImage(
                                url: URL(string: coreState.user.image),
                                content: { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80)
                                        .clipShape(Circle())
                                },
                                placeholder: {
                                    Image("blank_profile_picture")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80)
                                        .clipShape(Circle())
                                }
                            )
                            
                            VStack(alignment: .leading){
                                HStack{
                                    Image(systemName: "star.circle.fill")
                                    Text("\(coreState.user.grade)")
                                    Text("  \(coreState.user.nickname)")
                                }
                                HStack{
                                    Image(systemName: "phone.fill")
                                    Text("010\(coreState.user.phoneNumber)")
                                }.accentColor(.gray)
                                HStack{
                                    Image(systemName: "envelope.fill")
                                    Text("sampleemail@google.com")
                                }.accentColor(.gray)
                            }
                            .padding(.horizontal, 10)
                            Spacer()
                            if(isProfileDetailExpanded){
                                Image(systemName: "chevron.up")
                                    .font(.body.weight(.bold))
                            }else{
                                Image(systemName: "chevron.down")
                                    .font(.body.weight(.bold))
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 30))
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                    }
                    HStack{
                        Image(systemName: "wonsign.circle.fill")
                            .font(.body.weight(.bold))
                        Text("\(coreState.user.point) point")
                        Spacer()
                        Button{
                            coreState.navigate(Screen.Shop.route)
                        }label: {
                            Image(systemName: "bag")
                                .font(.body.weight(.bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .frame(height: 50)
                    .background(Color.brown)
                    .cornerRadius(10)
                    .padding(.horizontal, 15)
                    
                    VStack{
                        HStack{
                            Text("내 마스터 활동")
                            Text("( 총 \(coreState.user.activity)초 )")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        Divider()
                        VStack(spacing: 30){
                            DateScrollerView()
                                .environmentObject(dateHolder)
                                .padding()
                            HStack(spacing: 1){
                                Text("Sun").dayOfWeek()
                                Text("Mon").dayOfWeek()
                                Text("Tue").dayOfWeek()
                                Text("Wed").dayOfWeek()
                                Text("Thu").dayOfWeek()
                                Text("Fri").dayOfWeek()
                                Text("Sat").dayOfWeek()
                            }
                            VStack(spacing: 20){
                                let daysInMonth = CalendarHelper().daysInMonth(dateHolder.date)
                                let firstDayOfMonth = CalendarHelper().firstOfMonth(dateHolder.date)
                                let startingSpaces = CalendarHelper().weekDay(firstDayOfMonth)
                                let prevMonth = CalendarHelper().minusMonth(dateHolder.date)
                                let daysInPrevMonth = CalendarHelper().daysInMonth(prevMonth)
                                
                                ForEach(0..<6){
                                    row in
                                    HStack(spacing: 1)
                                    {
                                        ForEach(1..<8)
                                        {
                                            column in
                                            let count = column + (row * 7)
                                            CalendarCell(count: count, startingSpaces:startingSpaces, daysInMonth: daysInMonth, daysInPrevMonth: daysInPrevMonth)
                                                .environmentObject(dateHolder)
                                            
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: .infinity)
                        }
                        .padding(.vertical, 30)
                    }
                    .padding(15)
                }
            }
            .scrollIndicators(.hidden)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ProfileEditView()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.body.weight(.bold))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("프로필")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}


extension Text {
    func dayOfWeek() -> some View {
        self.frame(maxWidth: .infinity)
            .padding(.top, 1)
            .lineLimit(1)
    }
}
