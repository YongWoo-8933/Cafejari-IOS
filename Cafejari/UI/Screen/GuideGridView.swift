//
//  GuideGridView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI

struct GuideGridView: View {
    
    var body: some View {
        VStack{
            LazyVGrid(columns: GridItem(.flexible()).setGridColumn(columns: 2), spacing: 10) {
                ForEach(Guide.guides) { guide in
                    NavigationLink {
                        GuideView(guideImages: guide.images)
                    } label: {
                        Image(guide.titleImage)
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
    }
}

struct GuideGridView_Previews: PreviewProvider {
    static var previews: some View {
        GuideGridView()
    }
}
