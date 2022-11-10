//
//  LeaderBoardView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/04.
//

import SwiftUI

struct LeaderBoardView: View {
    var body: some View {
        NavigationView {
            Text("여기는 리더보드")
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("랭킹")
        }
    }
}
