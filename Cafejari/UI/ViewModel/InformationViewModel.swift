//
//  InformationViewModel.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation
import SwiftUI

@MainActor
final class InformationViewModel: BaseViewModel {
    
    @Published var events: Events = []
    @Published var randomEvent: Event? = nil
    @Published var pointPolicies: Paragraphs = []
    @Published var cautions: Paragraphs = []
    @Published var faqs: Paragraphs = []
    @Published var isInformationLoading: Bool = false
    
    @Published var isMinorUpdateDialogOpened: Bool = false
    @Published var isMajorUpdateDialogOpened: Bool = false
    @Published var majorUpdateDialogSecond: Int = 5
    
    @Inject var informationRepository: InformationRepository
    
    func checkAppVersion() async {
        do {
            let latestVersionList = try await informationRepository.fetchIosVersion()
            if !latestVersionList.isEmpty {
                let latestVersion = latestVersionList[0]
                if latestVersion.release > Version.current.release || latestVersion.major > Version.current.major {
                    isMajorUpdateDialogOpened = true
                    let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                        DispatchQueue.main.async {
                            self.majorUpdateDialogSecond -= 1
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        timer.invalidate()
                        self.majorUpdateDialogSecond = 5
                        self.navigateToAppstore()
                    }
                } else if latestVersion.minor > Version.current.minor {
                    guard let updateDisabledDate = await informationRepository.getUpdateDisabledDate() else {
                        isMinorUpdateDialogOpened = true
                        return
                    }
                    let calendar = Calendar.current
                    let date = calendar.dateComponents([.year, .month, .day], from: updateDisabledDate)
                    let now = calendar.dateComponents([.year, .month, .day], from: Date.now)
                    
                    if date.year == now.year && date.month == now.month && date.day == now.day {
                        
                    } else {
                        isMinorUpdateDialogOpened = true
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func getEvents(coreState: CoreState) async {
        do {
            self.events = try await informationRepository.fetchEvents()
            if !self.events.isEmpty {
                let randomEventIndex = Int.random(in: 0 ..< self.events.count)
                self.randomEvent = self.events[randomEventIndex]
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
    
    func getInfomations(coreState: CoreState) async {
        self.pointPolicies.removeAll()
        self.cautions.removeAll()
        self.faqs.removeAll()
        
        do {
            let faqResponses = try await informationRepository.fetchFAQs().sorted(by: { info1, info2 in
                return info1.order < info2.order
            })
            let pointPolicyResponses = try await informationRepository.fetchPointPolicies().sorted(by: { info1, info2 in
                return info1.order < info2.order
            })
            let cautionResponses = try await informationRepository.fetchCautions().sorted(by: { info1, info2 in
                return info1.order < info2.order
            })
            faqResponses.forEach { res in
                self.faqs.append(Paragraph(title: res.question, content: res.answer))
            }
            pointPolicyResponses.forEach { res in
                if res.image != String.NoneImage {
                    self.pointPolicies.append(Paragraph(title: res.sub_title, content: res.sub_content, image: res.image))
                } else {
                    self.pointPolicies.append(Paragraph(title: res.sub_title, content: res.sub_content))
                }
            }
            cautionResponses.forEach { res in
                self.cautions.append(Paragraph(title: res.sub_title, content: res.sub_content))
            }
            isInformationLoading = false
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
            isInformationLoading = false
        } catch {
            print(error)
            isInformationLoading = false
        }
    }
    
    func submitInquiryCafe(coreState: CoreState, name: String, address: String) async {
        do {
            try await informationRepository.postInquiryCafe(
                accessToken: coreState.accessToken,
                email: coreState.user.email,
                cafeName: name,
                cafeAddress: address
            )
            coreState.showSnackBar(message: "카페 등록 요청을 제출하였습니다. 결과는 알림을 통해 알려드립니다")
            coreState.popUp()
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await submitInquiryCafe(coreState: coreState, name: name, address: address)
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
    
    func submitInquiryEtc(coreState: CoreState, content: String) async {
        do {
            try await informationRepository.postInquiryEtc(
                accessToken: coreState.accessToken,
                email: coreState.user.email,
                content: content
            )
            coreState.popUp()
            coreState.showSnackBar(message: "문의를 제출하였습니다. 가입하신 이메일로 빠른 시일내에 답변드리겠습니다")
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await submitInquiryEtc(coreState: coreState, content: content)
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
    
    func navigateToAppstore() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/6444637809"),
                            UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
