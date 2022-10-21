//
//  PromotionView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI
import CachedAsyncImage

struct PromotionView: View {
    
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject private var informationViewModel: InformationViewModel
    
    var body: some View {
        VStack {
            ScrollView{
                LazyVStack{
                    Divider()
                    ForEach(informationViewModel.events, id: \.id) { event in
                        Button {
                            openURL(URL(string: event.url)!)
                        } label: {
                            VStack(alignment: .leading){
                                CachedAsyncImage(
                                    url: URL(string: event.image),
                                    content: { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity)
                                            .cornerRadius(20)
                                    },
                                    placeholder: {
                                        ProgressView()
                                    }
                                )
                                Text(event.name)
                                    .padding(.bottom, 8)
                                Text(event.preview)
                                Text("\(event.start) ~ \(event.finish)")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(10)
                        }
                        Divider()
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("공지 & 이벤트")
        .task {
            if informationViewModel.events.isEmpty {
                await informationViewModel.getEvents()
            }
        }
    }
}

struct PromotionView_Previews: PreviewProvider {
    static var previews: some View {
        PromotionView()
    }
}
