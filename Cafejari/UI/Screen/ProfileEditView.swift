//
//  ProfileEditView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    
    private enum Field: Int, CaseIterable {
        case nickname
    }
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @State private var isAuthenticated = false
    @State private var nickname = ""
    @State private var isImagePickerOpened = false
    @State private var uiImage: UIImage? = nil
    @State private var isPhotoLibraryPermitted: Bool = false
    
    @State var isGoogleLoginLoading = false
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ZStack {
            VStack {
                if !isAuthenticated {
                    Text("프로필 정보 변경을 위해 인증을 진행해주세요")
                    switch(userViewModel.socialUserType) {
                    case .kakao:
                        KakaoLoginButton(isLoading: $userViewModel.isKakaoLoginLoading) { accessToken in
                            Task{
                                let res = await userViewModel.loginWithKakaoForAuth(
                                    coreState: coreState,
                                    kakaoAccessToken: accessToken
                                )
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    isAuthenticated = res
                                }
                            }
                        } onFailure: { errorMessage in
                            print(errorMessage)
                        }
                    case .google:
                        GoogleLoginButton(isLoading: $isGoogleLoginLoading) { email, code in
                            Task{
                                let res = await userViewModel.loginWithGoogleForAuth(coreState: coreState, email: email, code:code)
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    isAuthenticated = res
                                }
                            }
                        } onFailure: { errorMessage in
                            print(errorMessage)
                        }
                    case .apple:
                        AppleLoginButton(isLoading: $userViewModel.isAppleLoginLoading) { idToken, code in
                            Task {
                                let res = await userViewModel.loginWithAppleForAuth(coreState: coreState, idToken: idToken, code: code)
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    isAuthenticated = res
                                }
                            }
                        } onFailure: { errorMessage in
                            print(errorMessage)
                        }
                    default:
                        ProgressView()
                            .foregroundColor(.black)
                    }
                } else {
                    HStack(spacing: 20) {
                        ZStack(alignment: .bottomTrailing) {
                            RoundProfileImage(120)
                                .shadow(radius: 1)
                            VStack {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(10)
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                        }
                        .frame(width: 120, height: 120)
                        .onTapGesture {
                            if isPhotoLibraryPermitted {
                                isImagePickerOpened = true
                            } else {
                                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                                    switch status {
                                    case .authorized:
                                        isImagePickerOpened = true
                                        isPhotoLibraryPermitted = true
                                    case .denied, .limited:
                                        guard let url = URL(string: UIApplication.openSettingsURLString),
                                              UIApplication.shared.canOpenURL(url) else {
                                            assertionFailure("Not able to open App privacy settings")
                                            return
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                        }
                                    case .notDetermined:
                                        print("결정장애")
                                    default:
                                        print("취소?")
                                    }
                                }
                            }
                        }
                        if let uiImage = uiImage {
                            Image(systemName: "chevron.right")
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120)
                                .clipShape(Circle())
                                .shadow(radius: 1)
                        }
                    }
                    HStack {
                        Text("닉네임 변경 :")
                        TextField("", text: $nickname)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: Field.nickname)
                            .frame(width: 200)
                    }
                }
            }
            FullScreenLoadingView(loading: $userViewModel.isProfileEditLoading, text: "변경사항 저장중..")
        }
        .sheet(isPresented: $isImagePickerOpened) {
            SheetHandle()
            GeometryReader { geo in
                LazyVStack {
                    UIImagePicker(image: $uiImage)
                        .frame(height: geo.size.height)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        userViewModel.isProfileEditLoading = true
                    }
                    Task {
                        await userViewModel.updateProfile(coreState: coreState, nickname: nickname, image: uiImage)
                    }
                } label: {
                    Text("저장")
                }
                .disabled(uiImage == nil && coreState.user.nickname == nickname)
            }
            ToolbarItem(placement: .keyboard) {
                Button{
                    focusedField = nil
                }label: {
                    HStack{
                        Text("완료")
                        Image(systemName: "chevron.down")
                    }
                    .frame(width: 600)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("회원정보 변경")
        .task {
            await userViewModel.getSocialUserType(coreState: coreState)
            nickname = coreState.user.nickname
            if PHPhotoLibrary.authorizationStatus() == .authorized {
                isPhotoLibraryPermitted = true
            }
        }
    }
}
