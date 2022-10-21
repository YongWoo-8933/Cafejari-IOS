//
//  ProfileEditView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI

struct ProfileEditView: View {
    var body: some View {
        VStack {
            Text("여기는 프로필 수정 화면")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Text("저장")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("회원정보 변경")
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView()
    }
}
