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
    @EnvironmentObject private var loginViewModel: LoginViewModel
    
    @State private var isAuthenticated = false
    @State private var nickname = ""
    @State private var isImagePickerOpened = false
    @State private var uiImage: UIImage? = nil
    @State private var isPhotoLibraryPermitted: Bool = false
    @State private var isSettingNavigateDialogOpened: Bool = false
    
    @State var isGoogleLoginLoading = false
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationTitle(title: "프로필 편집", leadingIconSystemName: "chevron.backward") {
                    coreState.popUp()
                }
                VStack(spacing: 0) {
                    VerticalSpacer(.moreLarge)
                    
                    if !isAuthenticated {
                        Text("프로필 정보 변경을 위해 인증을 진행해주세요")
                            .font(.headline)
                        
                        VerticalSpacer(40)
                        
                        switch(loginViewModel.socialUserType) {
                        case .kakao:
                            KakaoLoginButton(isLoading: $loginViewModel.isKakaoLoginLoading) { accessToken in
                                Task {
                                    isAuthenticated = await loginViewModel.loginWithKakaoForAuth(
                                        coreState: coreState,
                                        kakaoAccessToken: accessToken
                                    )
                                }
                            } onFailure: { errorMessage in
                                print(errorMessage)
                            }
                        case .google:
                            GoogleLoginButton(isLoading: $isGoogleLoginLoading) { email, code in
                                Task{
                                    isAuthenticated = await loginViewModel.loginWithGoogleForAuth(coreState: coreState, email: email, code:code)
                                }
                            } onFailure: { errorMessage in
                                print(errorMessage)
                            }
                        case .apple:
                            AppleLoginButton(isLoading: $loginViewModel.isAppleLoginLoading) { idToken, code in
                                Task {
                                    isAuthenticated = await loginViewModel.loginWithAppleForAuth(coreState: coreState, idToken: idToken, code: code)
                                }
                            } onFailure: { errorMessage in
                                print(errorMessage)
                            }
                        default:
                            ProgressView()
                        }
                    } else {
                        HStack(spacing: .large) {
                            RoundProfileImage(image: coreState.user.image, size: 100)
                            if let uiImage = uiImage {
                                Image(systemName: "chevron.forward")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .clipShape(Circle())
                                    .shadow(radius: 1)
                            }
                        }
                        
                        VerticalSpacer(.large)
                        
                        Text("프로필 사진 수정")
                            .font(.body.bold())
                            .foregroundColor(.primary)
                            .frame(width: 128, height: 32)
                            .roundBorder(cornerRadius: 16, lineWidth: 1.5, borderColor: .primary)
                            .onTapGesture {
                                if isPhotoLibraryPermitted {
                                    isImagePickerOpened = true
                                } else {
                                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                                        switch status {
                                        case .authorized:
                                            isImagePickerOpened = true
                                            isPhotoLibraryPermitted = true
                                        default:
                                            isSettingNavigateDialogOpened = true
                                        }
                                    }
                                }
                            }
                        
                        VerticalSpacer(32)
                        
                        TextField("변경할 닉네임", text: $nickname)
                            .textFieldStyle(SingleLineTextFieldStyle())
                            .focused($focusedField, equals: Field.nickname)
                        
                        VerticalSpacer(.medium)
                        
                        VStack(spacing: .small) {
                            Text(nickname.isNicknameLengthValid() ? "닉네임 길이가 적당합니다" : "닉네임은 2~10자로 정해주세요")
                                .foregroundColor(nickname.isNicknameLengthValid() ? .lightGray : .textSecondary)
                            Text(nickname.hasSpecialChar() || nickname.isEmpty ? "특수문자 및 공백이 허용되지 않습니다" : "닉네임 구성이 유효합니다")
                                .foregroundColor(nickname.hasSpecialChar() || nickname.isEmpty ? .textSecondary : .lightGray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VerticalSpacer(40)
                        
                        FilledCtaButton(text: "변경사항 저장", backgroundColor: .secondary) {
                            if coreState.user.nickname == nickname && uiImage == nil {
                                coreState.showSnackBar(message: "변경 사항이 없습니다", type: SnackBarType.info)
                            } else {
                                userViewModel.isProfileEditLoading = true
                                Task {
                                    await userViewModel.updateProfile(coreState: coreState, nickname: nickname, image: uiImage)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.moreLarge)
                .animation(.easeInOut, value: isAuthenticated)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            Dialog(
                isDialogVisible: $isSettingNavigateDialogOpened,
                positiveButtonText: "허용하러 가기",
                negativeButtonText: "",
                onPositivebuttonClick: {
                    guard let url = URL(string: UIApplication.openSettingsURLString),
                          UIApplication.shared.canOpenURL(url) else {
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                },
                onNegativebuttonClick: {},
                onDismiss: {}
            ) {
                Text("프로필 사진을 변경하기위해 저장소 권한이 필요합니다.\n\n")
                    .font(.headline)
                +
                Text("설정에서 ")
                +
                Text("모든 사진 접근권한")
                    .font(.body.bold())
                +
                Text("을\n허용해주세요\n\n")
                +
                Text("*설정 변경시 앱이 재시작됩니다")
                    .font(.caption)
                    .foregroundColor(.heavyGray)
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
        .navigationBarBackButtonHidden()
        .addKeyboardDownButton {
            focusedField = nil
        }
        .task {
            await loginViewModel.getSocialUserType(coreState: coreState)
            nickname = coreState.user.nickname
            if PHPhotoLibrary.authorizationStatus() == .authorized {
                isPhotoLibraryPermitted = true
            }
        }
    }
}
