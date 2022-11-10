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
    
//    @Published var randomTip: Tip = Tip.empty
//    @Published var isRandomTipLoading: Bool = true
    @Published var events: Events = []
    @Published var pointPolicies: Paragraphs = []
    @Published var cautions: Paragraphs = []
    @Published var faqs: Paragraphs = []
    @Published var isInformationLoading: Bool = false
    
    @Inject var informationRepository: InformationRepository
    
//    func getRandomTip() async {
//        self.isRandomTipLoading = true
//        do {
//            self.randomTip = try await informationRepository.fetchRandomTip()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                withAnimation(.easeInOut(duration: 0.1)) {
//                    self.isRandomTipLoading = false
//                }
//            }
//        } catch {
//            print(error)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                withAnimation(.easeInOut(duration: 0.1)) {
//                    self.isRandomTipLoading = false
//                }
//            }
//        }
//    }
    
    func getEvents(coreState: CoreState) async {
        do {
            self.events = try await informationRepository.fetchEvents()
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
                if res.image != GlobalString.NoneImage.rawValue {
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
    
    func submitInquiryCafe(coreState: CoreState, name: String, address: String, onSuccess: () -> Void) async {
        do {
            try await informationRepository.postInquiryCafe(
                accessToken: coreState.accessToken,
                email: coreState.user.email,
                cafeName: name,
                cafeAddress: address
            )
            onSuccess()
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await submitInquiryCafe(coreState: coreState, name: name, address: address, onSuccess: onSuccess)
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
    
    func submitInquiryEtc(coreState: CoreState, content: String, onSuccess: () -> Void) async {
        do {
            try await informationRepository.postInquiryEtc(
                accessToken: coreState.accessToken,
                email: coreState.user.email,
                content: content
            )
            onSuccess()
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await submitInquiryEtc(coreState: coreState, content: content, onSuccess: onSuccess)
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
}
