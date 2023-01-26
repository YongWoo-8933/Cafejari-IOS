//
//  OnSaleCafeDialog.swift
//  Cafejari
//
//  Created by 안용우 on 2023/01/23.
//

import SwiftUI
import CachedAsyncImage

struct OnSaleCafeDialog: View {
    
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var coreState: CoreState
    
    let moveToConnectedCafe: (Int) -> Void
    
    var body: some View {
        let width = UIScreen.main.bounds.size.width * 0.75
        let height = UIScreen.main.bounds.size.height * 0.7
        ZStack {
            ZStack {
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.5))
            .opacity(informationViewModel.isOnSaleCafeDialogOpened ? 1 : 0)
            .onTapGesture {
                informationViewModel.isOnSaleCafeDialogOpened = false
            }
            
            VStack(spacing: 0) {
                VerticalSpacer(.large)
                if informationViewModel.onSaleCafes.isEmpty {
                    EmptyImageView("세일중인 카페가 없어요")
                        .frame(width: width)
                        .padding(.top, 60)
                        .padding(.bottom, 40)
                } else if informationViewModel.onSaleCafes.count < 3 {
                    ForEach(informationViewModel.onSaleCafes, id: \.order) { onSaleCafe in
                        OnSaleCafeItem(onSaleCafe: onSaleCafe) {
                            informationViewModel.isOnSaleCafeDialogOpened = false
                            moveToConnectedCafe(onSaleCafe.cafeInfoId)
                        }
                        .frame(width: width)
                        Divider()
                    }
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(informationViewModel.onSaleCafes, id: \.order) { onSaleCafe in
                                OnSaleCafeItem(onSaleCafe: onSaleCafe) {
                                    informationViewModel.isOnSaleCafeDialogOpened = false
                                    moveToConnectedCafe(onSaleCafe.cafeInfoId)
                                }
                                .frame(width: width)
                                Divider()
                            }
                        }
                    }
                    .scrollIndicators(.never)
                    .frame(width: width, height: height, alignment: .top)
                }
                    
                HStack(spacing: 0) {
                    Button {
                        informationViewModel.isOnSaleCafeDialogOpened = false
                    } label: {
                        Text("닫기")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(width: width, height: 54)
                    }
                }
                .background(Color.primary)
            }
            .frame(width: width)
            .background(.white)
            .cornerRadius(.moreLarge)
            .shadow(radius: 3)
            .opacity(informationViewModel.isOnSaleCafeDialogOpened ? 1 : 0)
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.easeInOut, value: informationViewModel.isOnSaleCafeDialogOpened)
    }
}


struct OnSaleCafeItem: View {
    
    let onSaleCafe: OnSaleCafe
    let onClick: () -> Void
    
    var body: some View {
        Button {
            onClick()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                CachedAsyncImage(
                    url: URL(string: onSaleCafe.image),
                    content: { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    },
                    placeholder: {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .heavyGray))
                            .frame(width: 44, height: 44)
                    }
                )
                VerticalSpacer(.large)
                HStack {
                    Text(onSaleCafe.cafeInfoName)
                        .font(.body.bold())
                    Text("이벤트")
                        .font(.caption2)
                        .padding(.horizontal, .small)
                        .padding(.vertical, 2)
                        .background(Color.secondary)
                        .cornerRadius(.small)
                        .foregroundColor(.white)
                }
                VerticalSpacer(.small)
                Text("\(onSaleCafe.cafeInfoCity) \(onSaleCafe.cafeInfoGu) \(onSaleCafe.cafeInfoAddress)")
                    .font(.caption)
                    .foregroundColor(.heavyGray)
            }
            .padding(.moreLarge)
        }
    }
}
