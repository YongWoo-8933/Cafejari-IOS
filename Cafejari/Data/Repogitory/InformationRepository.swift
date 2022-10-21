//
//  InformationRepository.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation

protocol InformationRepository {
    
    func fetchRandomSaying() async throws -> ImageSaying
    func fetchEvents() async throws -> Events
}



final class InformationRepositoryImpl: InformationRepository {
    
    @Inject var httpRoute: HttpRoute
    
    func fetchRandomSaying() async throws -> ImageSaying {
        let urlSession = URLSession.shared
        let url = URL( string: httpRoute.randomSaying() )
        let (data, _) = try await urlSession.data(from: url!)
        return try JSONDecoder().decode(ImageSaying.self, from: data)
    }
    
    func fetchEvents() async throws -> Events {
        let urlSession = URLSession.shared
        let url = URL( string: httpRoute.event() )
        let (data, _) = try await urlSession.data(from: url!)
        return try JSONDecoder().decode(Events.self, from: data)
    }
}
