//
//  InformationViewModel.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation

@MainActor
final class InformationViewModel: BaseViewModel {
    
    @Published var randomTip: ImageSaying = ImageSaying.empty
    @Published var events: Events = []
    
    @Inject var informationRepository: InformationRepository
    
    func getRandomTip() async {
        do {
            self.randomTip = try await informationRepository.fetchRandomSaying()
        } catch {
            print(error)
        }
    }
    
    func getEvents() async {
        do {
            self.events = try await informationRepository.fetchEvents()
        } catch {
            print(error)
        }
    }
}
