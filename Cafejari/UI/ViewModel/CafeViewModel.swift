//
//  CafeViewModel.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/21.
//

import Foundation

@MainActor
final class CafeViewModel: BaseViewModel {
    
    @Inject var cafeRepository: CafeRepository
    
    @Published var cafeInfos: CafeInfos = []
    
    func getCafeInfos(coreState: CoreState) async throws {
        let cafeInfoResponses = try await cafeRepository.fetchCafeInfos(accessToken: coreState.accessToken)
        var newCafeInfos: CafeInfos = []
        
        cafeInfoResponses.forEach { cafeInfoResponse in
            var cafes: Cafes = []
            
            cafeInfoResponse.cafe.forEach { cafeInfoCafeResponse in
                var recentUpdatedLogs: RecentUpdatedLogs = []
                
                cafeInfoCafeResponse.recent_updated_log.forEach { recentUpdatedLogResponse in
                    let recentUpdatedLog = RecentUpdatedLog(
                        id: recentUpdatedLogResponse.id,
                        master: CafeMaster(
                            userId: recentUpdatedLogResponse.cafe_detail_log.cafe_log.master.id,
                            nickname: recentUpdatedLogResponse.cafe_detail_log.cafe_log.master.profile?.nickname ?? "",
                            grade: recentUpdatedLogResponse.cafe_detail_log.cafe_log.master.profile?.grade ?? 0
                        ),
                        update: recentUpdatedLogResponse.update,
                        crowded: recentUpdatedLogResponse.cafe_detail_log.crowded
                    )
                    recentUpdatedLogs.append(recentUpdatedLog)
                }
                
                let cafe = Cafe(
                    id: cafeInfoCafeResponse.id,
                    crowded: recentUpdatedLogs.isEmpty ? -1 : recentUpdatedLogs[0].crowded,
                    master: CafeMaster(
                        userId: cafeInfoCafeResponse.master?.id ?? 0,
                        nickname: cafeInfoCafeResponse.master?.profile?.nickname ?? "",
                        grade: cafeInfoCafeResponse.master?.profile?.grade ?? 0
                    ),
                    floor: cafeInfoCafeResponse.floor,
                    recentUpdatedLogs: recentUpdatedLogs
                )
                cafes.append(cafe)
            }
            
            newCafeInfos.append(
                CafeInfo(
                    id: cafeInfoResponse.id,
                    name: cafeInfoResponse.name,
                    city: cafeInfoResponse.city,
                    gu: cafeInfoResponse.gu,
                    address: cafeInfoResponse.address,
                    totalFloor: cafeInfoResponse.total_floor,
                    floor: cafeInfoResponse.floor,
                    latitude: cafeInfoResponse.latitude,
                    longitude: cafeInfoResponse.longitude,
                    googlePlaceId: cafeInfoResponse.google_place_id,
                    cafes: cafes
                )
            )
        }
        
        self.cafeInfos = newCafeInfos
    }
}
