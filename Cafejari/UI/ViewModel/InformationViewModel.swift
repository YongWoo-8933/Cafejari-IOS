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
    
    @Published var unExpiredEvents: Events = []
    @Published var expiredEvents: Events = []
    @Published var randomEvent: Event? = nil
    @Published var faqs: Paragraphs = []
    @Published var myInquiryCafes: InquiryCafes = []
    @Published var myInquiryEtcs: InquiryEtcs = []
    @Published var popUpNotifications: PopUpNotifications = []
    @Published var onSaleCafes: OnSaleCafes = []
    @Published var isPopUpTriggered: Bool = false
    @Published var isAssociatedCafeDescriptionOpened: Bool = false
    @Published var isOnSaleCafeDialogOpened: Bool = false
    @Published var isFaqsLoading: Bool = true
    @Published var isMyInquiryCafeLoading: Bool = true
    @Published var isMyInquiryEtcLoading: Bool = true
    
    @Published var isMinorUpdateDialogOpened: Bool = false
    @Published var isMajorUpdateDialogOpened: Bool = false
    @Published var majorUpdateDialogSecond: Int = 5
    
    private var associatedCafeDesriptionWork: DispatchWorkItem? = nil
    
    @Inject var informationRepository: InformationRepository
    
    func checkAppVersion() async {
        do {
            let latestVersionList = try await informationRepository.fetchIosVersion()
            if !latestVersionList.isEmpty {
                let latestVersion = latestVersionList[0]
                
                if latestVersion.release > Version.current.release {
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
                } else if latestVersion.release == Version.current.release && latestVersion.major > Version.current.major {
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
                } else if latestVersion.release == Version.current.release && latestVersion.major == Version.current.major && latestVersion.minor > Version.current.minor {
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
            let events = try await informationRepository.fetchEvents()
            self.unExpiredEvents.removeAll()
            self.expiredEvents.removeAll()
            if !events.isEmpty {
                events.forEach { event in
                    if time.isPast(timeString: event.finish) {
                        self.expiredEvents.append(event)
                    } else {
                        self.unExpiredEvents.append(event)
                    }
                }
                let randomEventIndex = Int.random(in: 0 ..< self.unExpiredEvents.count)
                self.randomEvent = self.unExpiredEvents[randomEventIndex]
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
    
    func getPopUpNotifications(coreState: CoreState) async {
        do {
            let popUpNotificationResponses = try await informationRepository.fetchPopUpNotifications().sorted(by: { popUp1, popUp2 in
                popUp1.order < popUp2.order
            })
            self.popUpNotifications.removeAll()
            popUpNotificationResponses.forEach { res in
                self.popUpNotifications.append(
                    PopUpNotification(
                        order: res.order,
                        url: res.url,
                        image: res.image,
                        cafeInfoId: res.cafe_info ?? 0
                    )
                )
            }
            isPopUpTriggered = true
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
    
    func getOnSaleCafes(coreState: CoreState) async {
        do {
            let onSaleCafeResponses = try await informationRepository.fetchOnSaleCafes().sorted(by: { onSaleCafe1, onSaleCafe2 in
                onSaleCafe1.order < onSaleCafe2.order
            })
            self.onSaleCafes.removeAll()
            onSaleCafeResponses.forEach { res in
                self.onSaleCafes.append(
                    OnSaleCafe(
                        order: res.order,
                        content: res.content,
                        image: res.image,
                        cafeInfoId: res.cafe_info.id,
                        cafeInfoName: res.cafe_info.name,
                        cafeInfoCity: res.cafe_info.city,
                        cafeInfoGu: res.cafe_info.gu,
                        cafeInfoAddress: res.cafe_info.address,
                        cafeInfoLatitude: res.cafe_info.latitude,
                        cafeInfoLongitude: res.cafe_info.longitude
                    )
                )
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
    
    func getOnSaleCafeFromId(cafeInfoId: Int) -> OnSaleCafe? {
        return self.onSaleCafes.first { onSaleCafe in
            onSaleCafe.cafeInfoId == cafeInfoId
        }
    }
    
    func getFaqs(coreState: CoreState) async {
        self.faqs.removeAll()
        self.isFaqsLoading = true
        
        do {
            let faqResponses = try await informationRepository.fetchFAQs().sorted(by: { info1, info2 in
                return info1.order < info2.order
            })
            faqResponses.forEach { res in
                self.faqs.append(Paragraph(order: res.order, title: res.question, content: res.answer))
            }
            isFaqsLoading = false
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
            isFaqsLoading = false
        } catch {
            print(error)
            isFaqsLoading = false
        }
    }
    
    func getMyInquiryCafes(coreState: CoreState) async {
        self.myInquiryCafes.removeAll()
        self.isMyInquiryCafeLoading = true
        
        do {
            let inquiryCafeResponses = try await informationRepository.fetchInquiryCafes(accessToken: coreState.accessToken).sorted(by: { inq1, inq2 in
                inq1.id > inq2.id
            })
            inquiryCafeResponses.forEach { res in
                self.myInquiryCafes.append(
                    InquiryCafe(
                        id: res.id,
                        name: res.cafe_name,
                        address: res.cafe_address,
                        result: res.result ?? "",
                        requestDate: "\(self.time.parseYearFrom(timeString: res.time)).\(self.time.parseMonthFrom(timeString: res.time)).\(self.time.parseDayFrom(timeString: res.time))"
                    )
                )
            }
            self.isMyInquiryCafeLoading = false
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await getMyInquiryCafes(coreState: coreState)
            })
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
            self.isMyInquiryCafeLoading = false
        } catch {
            print(error)
            self.isMyInquiryCafeLoading = false
        }
    }
    
    func getMyInquiryEtcs(coreState: CoreState) async {
        self.myInquiryEtcs.removeAll()
        self.isMyInquiryEtcLoading = true
        
        do {
            let inquiryEtcResponses = try await informationRepository.fetchInquiryEtcs(accessToken: coreState.accessToken).sorted(by: { inq1, inq2 in
                inq1.id > inq2.id
            })
            inquiryEtcResponses.forEach { res in
                self.myInquiryEtcs.append(
                    InquiryEtc(
                        id: res.id,
                        content: res.content,
                        answer: res.answer ?? "",
                        requestDate: "\(self.time.parseYearFrom(timeString: res.time)).\(self.time.parseMonthFrom(timeString: res.time)).\(self.time.parseDayFrom(timeString: res.time))"
                    )
                )
            }
            self.isMyInquiryEtcLoading = false
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await getMyInquiryEtcs(coreState: coreState)
            })
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
            self.isMyInquiryEtcLoading = false
        } catch {
            print(error)
            self.isMyInquiryEtcLoading = false
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
            coreState.showSnackBar(message: "카페등록 요청을 제출하였습니다")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                coreState.navigate(Screen.CafeInquiryResult.route)
            }
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
            coreState.showSnackBar(message: "문의를 제출하였습니다")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                coreState.navigate(Screen.InquiryAnswer.route)
            }
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
    
    func deleteInquiryCafe(coreState: CoreState, selectedInquiryCafeId: Int) async {
        do {
            try await informationRepository.deleteInquiryCafe(accessToken: coreState.accessToken, inquiryCafeId: selectedInquiryCafeId)
            await self.getMyInquiryCafes(coreState: coreState)
            coreState.showSnackBar(message: "카페 등록요청 기록을 삭제했습니다")
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await deleteInquiryCafe(coreState: coreState, selectedInquiryCafeId: selectedInquiryCafeId)
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
    
    func deleteInquiryEtc(coreState: CoreState, selectedInquiryEtcId: Int) async {
        do {
            try await informationRepository.deleteInquiryEtc(accessToken: coreState.accessToken, inquiryEtcId: selectedInquiryEtcId)
            await self.getMyInquiryEtcs(coreState: coreState)
            coreState.showSnackBar(message: "문의 내역을 삭제했습니다")
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await deleteInquiryEtc(coreState: coreState, selectedInquiryEtcId: selectedInquiryEtcId)
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
    
    func isTodayPopUpVisible() async -> Bool {
        guard let popUpDisabledDate = await informationRepository.getPopUpDisabledDate() else {
            return true
        }
        let calendar = Calendar.current
        let date = calendar.dateComponents([.year, .month, .day], from: popUpDisabledDate)
        let now = calendar.dateComponents([.year, .month, .day], from: Date.now)
        
        if date.year == now.year && date.month == now.month && date.day == now.day {
            return false
        } else {
            return true
        }
    }
}
