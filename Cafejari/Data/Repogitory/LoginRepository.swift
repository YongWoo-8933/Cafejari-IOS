//
//  LoginRepository.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/12.
//

import Foundation


protocol LoginRepository {
    
    func requestKakaoLogin(accessToken: String) async throws -> KakaoLoginResponse
    func requestKakaoLoginFinish(accessToken: String) async throws -> LoginResponse
    func requestGoogleLogin(email: String, code: String) async throws -> GoogleLoginResponse
    func requestGoogleLoginFinish(accessToken: String, code: String) async throws -> LoginResponse
    func requestAppleLogin(idToken: String, code: String) async throws -> AppleLoginResponse
    func requestAppleLoginFinish(idToken: String, code: String) async throws -> LoginResponse
    func postPreAuthorization(nickname: String, phoneNumber: String) async throws -> PreAuthResponse
    func makeNewProfile(accessToken: String, userId: Int, nickname: String, phoneNumber: String, fcmToken: String) async throws -> UserResponse
    func sendSms(phoneNumber: String) async throws
    func authSms(authNumber: String, phoneNumber: String) async throws
    func fetchSocialUserType(accessToken: String) async throws -> SocialUserTypeResponse
}


final class LoginRepositoryImpl: LoginRepository {
    
    @Inject var httpRoute: HttpRoute
    @Inject var customUrlRequest: CustomURLRequest
    
    func requestKakaoLogin(accessToken: String) async throws -> KakaoLoginResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(urlString: httpRoute.kakaoLogin(), requestBody: ["access_token" : accessToken])
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 409 {
                let errorCodeRes = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
                switch errorCodeRes.error_code {
                case 401:
                    let errorCodeWithDetailRes = try JSONDecoder().decode(ErrorCodeWithDetailResponse.self, from: data)
                    throw CustomError.errorMessage("해당 이메일은 \(errorCodeWithDetailRes.detail) 계정으로 가입되어 있습니다")
                case 402:
                    throw CustomError.errorMessage("카카오 계정에 등록된 이메일이 없습니다. 카카오계정 프로필에 이메일 등록후 진행해주세요")
                default:
                    throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                }
                
            } else if (200..<300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(KakaoLoginResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func requestKakaoLoginFinish(accessToken: String) async throws -> LoginResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.kakaoLoginFinish(),
                requestBody: ["access_token" : accessToken, "code": ""]
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(LoginResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func requestGoogleLogin(email: String, code: String) async throws -> GoogleLoginResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(urlString: httpRoute.googleLogin(), requestBody: ["email" : email, "code": code])
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 409 {
                let errorCodeRes = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
                switch errorCodeRes.error_code {
                case 400:
                    let errorCodeWithDetailRes = try JSONDecoder().decode(ErrorCodeWithDetailResponse.self, from: data)
                    throw CustomError.errorMessage("구글 로그인 오류: \(errorCodeWithDetailRes.detail)")
                case 401:
                    let errorCodeWithDetailRes = try JSONDecoder().decode(ErrorCodeWithDetailResponse.self, from: data)
                    throw CustomError.errorMessage("해당 이메일은 \(errorCodeWithDetailRes.detail) 계정으로 가입되어 있습니다")
                default:
                    throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                }
                
            } else if (200..<300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(GoogleLoginResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func requestGoogleLoginFinish(accessToken: String, code: String) async throws -> LoginResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.googleLoginFinish(),
                requestBody: ["access_token" : accessToken, "code": code]
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if (200..<300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(LoginResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func requestAppleLogin(idToken: String, code: String) async throws -> AppleLoginResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.appleLogin(),
                requestBody: ["id_token": idToken, "code": code]
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 409 {
                let errorCodeRes = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
                switch errorCodeRes.error_code {
                case 401:
                    let errorCodeWithDetailRes = try JSONDecoder().decode(ErrorCodeWithDetailResponse.self, from: data)
                    throw CustomError.errorMessage("해당 이메일은 \(errorCodeWithDetailRes.detail) 계정으로 가입되어 있습니다")
                case 402:
                    throw CustomError.errorMessage("애플 계정에 등록된 이메일이 없습니다. 애플계정 프로필에 이메일 등록후 진행해주세요")
                default:
                    throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                }
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(AppleLoginResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func requestAppleLoginFinish(idToken: String, code: String) async throws -> LoginResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.appleLoginFinish(),
                requestBody: ["id_token" : idToken, "code": code, "access_token": ""]
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if (200..<300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(LoginResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func postPreAuthorization(nickname: String, phoneNumber: String) async throws -> PreAuthResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.preAuthorization(), requestBody: ["nickname" : nickname, "phone_number": phoneNumber])
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 400 {
                if let nicknameErrorRes = try? JSONDecoder().decode(NicknameErrorResponse.self, from: data) {
                    var msg = nicknameErrorRes.nickname[0]
                    if msg == "profile의 nickname은/는 이미 존재합니다." {
                        msg = "중복되는 닉네임입니다"
                    }
                    throw CustomError.errorMessage(msg)
                }
                if let phoneNumberErrorRes = try? JSONDecoder().decode(PhoneNumberErrorResponse.self, from: data) {
                    var msg = phoneNumberErrorRes.phone_number[0]
                    if msg == "profile의 phone number은/는 이미 존재합니다." {
                        msg = "이미 가입에 사용된 번호입니다"
                    }
                    throw CustomError.errorMessage(msg)
                }
                if let nicknamePhoneNumberErrorRes = try? JSONDecoder().decode(NicknamePhoneNumberErrorResponse.self, from: data) {
                    var nicknameMsg = nicknamePhoneNumberErrorRes.nickname[0]
                    var phoneNumberMsg = nicknamePhoneNumberErrorRes.phone_number[0]
                    
                    if phoneNumberMsg == "profile의 phone number은/는 이미 존재합니다." {
                        phoneNumberMsg = "이미 가입에 사용된 번호입니다"
                    }
                    if nicknameMsg == "profile의 nickname은/는 이미 존재합니다." {
                        nicknameMsg = "중복되는 닉네임입니다"
                    }
                    throw CustomError.errorMessage(nicknameMsg + "\n" + phoneNumberMsg)
                }
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                
            } else if httpUrlRes.statusCode == 409 {
                let errorCodeRes = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
                switch errorCodeRes.error_code {
                case 404:
                    throw CustomError.errorMessage("번호 인증을 먼저 진행해주세요")
                default:
                    throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                }
                
            } else if (200..<300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(PreAuthResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func makeNewProfile(accessToken: String, userId: Int, nickname: String, phoneNumber:String, fcmToken: String) async throws -> UserResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.makeNewProfile(),
                accessToken: accessToken,
                requestBody: ["user": userId, "nickname": nickname, "phone_number": phoneNumber, "fcm_token": fcmToken]
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 400 {
                if let nicknameErrorRes = try? JSONDecoder().decode(NicknameErrorResponse.self, from: data) {
                    var msg = nicknameErrorRes.nickname[0]
                    if msg == "profile의 nickname은/는 이미 존재합니다." {
                        msg = "중복되는 닉네임입니다"
                    }
                    throw CustomError.errorMessage(msg)
                }
                if let phoneNumberErrorRes = try? JSONDecoder().decode(PhoneNumberErrorResponse.self, from: data) {
                    var msg = phoneNumberErrorRes.phone_number[0]
                    if msg == "profile의 phone number은/는 이미 존재합니다." {
                        msg = "이미 가입에 사용된 번호입니다"
                    }
                    throw CustomError.errorMessage(msg)
                }
                if let nicknamePhoneNumberErrorRes = try? JSONDecoder().decode(NicknamePhoneNumberErrorResponse.self, from: data) {
                    var nicknameMsg = nicknamePhoneNumberErrorRes.nickname[0]
                    var phoneNumberMsg = nicknamePhoneNumberErrorRes.phone_number[0]
                    
                    if phoneNumberMsg == "profile의 phone number은/는 이미 존재합니다." {
                        phoneNumberMsg = "이미 가입에 사용된 번호입니다"
                    }
                    if nicknameMsg == "profile의 nickname은/는 이미 존재합니다." {
                        nicknameMsg = "중복되는 닉네임입니다"
                    }
                    throw CustomError.errorMessage(nicknameMsg + "\n" + phoneNumberMsg)
                }
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(UserResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func sendSms(phoneNumber: String) async throws {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.smsSend(),
                requestBody: ["phone_number" : phoneNumber]
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 409 {
                let errorCodeRes = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
                switch errorCodeRes.error_code {
                case 403:
                    throw CustomError.errorMessage("이미 인증에 사용된 번호입니다")
                case 407:
                    throw CustomError.errorMessage("인증번호 전송에 실패했습니다")
                default:
                    throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                }
                
            } else if (200..<300).contains(httpUrlRes.statusCode) {
                
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func authSms(authNumber: String, phoneNumber: String) async throws {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.post(
                urlString: httpRoute.smsAuth(),
                requestBody: ["phone_number" : phoneNumber, "auth_number": authNumber]
            )
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 409 {
                let errorCodeRes = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
                switch errorCodeRes.error_code {
                case 404:
                    throw CustomError.errorMessage("번호 인증을 먼저 진행해주세요")
                case 405:
                    throw CustomError.errorMessage("인증번호 발송 후 3분이 초과되었습니다. 다시 시도해주세요")
                case 406:
                    throw CustomError.errorMessage("인증번호가 일치하지 않습니다")
                default:
                    throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                }
                
            } else if (200..<300).contains(httpUrlRes.statusCode) {
                
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
    
    func fetchSocialUserType(accessToken: String) async throws -> SocialUserTypeResponse {
        do {
            let urlSession = URLSession.shared
            let request = customUrlRequest.get(urlString: httpRoute.socialUserCheck(), accessToken: accessToken)
            let (data, urlRes) = try await urlSession.data(for: request)
            
            guard let httpUrlRes = urlRes as? HTTPURLResponse
            else { throw CustomError.errorMessage("오류가 발생했습니다. 다시 시도해주세요") }
            
            if httpUrlRes.statusCode == 401 {
                _ = try JSONDecoder().decode(TokenExpiredErrorResponse.self, from: data)
                throw CustomError.accessTokenExpired
            } else if httpUrlRes.statusCode == 409 {
                let errorCodeRes = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
                switch errorCodeRes.error_code {
                case 404:
                    throw CustomError.errorMessage("번호 인증을 먼저 진행해주세요")
                default:
                    throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
                }
                
            } else if (200 ..< 300).contains(httpUrlRes.statusCode) {
                return try JSONDecoder().decode(SocialUserTypeResponse.self, from: data)
                
            } else {
                throw CustomError.errorMessage("내부 서버 오류입니다. 잠시 후에 다시 시도해주세요")
            }
        } catch CustomError.accessTokenExpired {
            throw CustomError.accessTokenExpired
        } catch CustomError.errorMessage(let msg) {
            throw CustomError.errorMessage(msg)
        } catch let error as NSError {
            throw nsErrorHandle(error)
        }
    }
}
