//
//  GoogleMapView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/20.
//

import SwiftUI
import GoogleMaps
import GooglePlaces

struct GoogleMapView: UIViewRepresentable {
    
    @EnvironmentObject var cafeViewModel: CafeViewModel
    @EnvironmentObject var coreState: CoreState
    
    @Binding var markerRefreshTrigger: Bool
    @Binding var animateTo: GMSCameraPosition?
    @Binding var mapType: MapType
    
    let startCameraPosition: GMSCameraPosition
    let onMarkerTap: (CafeInfo) -> Void
    let onMarkerInfoWindowTap: () -> Void
    
    private let markerHeight = 35.0
    private let grayMarkerUIImage = UIImage(named: Crowded.crowdedNegative.image)
    private let blueMarkerUIImage = UIImage(named: Crowded.crowdedZero.image)
    private let greenMarkerUIImage = UIImage(named: Crowded.crowdedOne.image)
    private let yellowMarkerUIImage = UIImage(named: Crowded.crowdedTwo.image)
    private let orangeMarkerUIImage = UIImage(named: Crowded.crowdedThree.image)
    private let redMarkerUIImage = UIImage(named: Crowded.crowdedFour.image)
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self, onMarkerTap: onMarkerTap, onMarkerInfoWindowTap: onMarkerInfoWindowTap)
    }
    
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView(frame: CGRect.zero, camera: startCameraPosition)
        
        // 기본설정
        mapView.isIndoorEnabled = true
        mapView.isTrafficEnabled = false
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.tiltGestures = false
        mapView.accessibilityElementsHidden = false
        mapView.isBuildingsEnabled = true
        mapView.delegate = context.coordinator
        
        return mapView
    }
         
     func updateUIView(_ uiView: GMSMapView, context: Context) {
         if markerRefreshTrigger {
             uiView.clear()
             DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.001) {
                 _ = self.drawMarkers(mapView: uiView)
                 markerRefreshTrigger = false
             }
         }
         if animateTo != nil {
             uiView.animate(to: animateTo ?? GMSCameraPosition.sinchon)
             DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                 animateTo = nil
             }
         }
     }
    
    func getCrowdedMarkerUIImage(crowded: Int) -> UIImage? {
        switch crowded {
        case Crowded.crowdedZero.value: return blueMarkerUIImage
        case Crowded.crowdedOne.value: return greenMarkerUIImage
        case Crowded.crowdedTwo.value: return yellowMarkerUIImage
        case Crowded.crowdedThree.value: return orangeMarkerUIImage
        case Crowded.crowdedFour.value: return redMarkerUIImage
        default: return grayMarkerUIImage
        }
    }

   func getMasterMarkerUIImage(available: Bool) -> UIImage? {
       return available ? greenMarkerUIImage : redMarkerUIImage
   }
    
    func drawMarkers(mapView: GMSMapView) -> GMSMapView {
        
        switch(mapType) {
        case .crowded:
            cafeViewModel.cafeInfos.forEach { cafeInfo in
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(
                    latitude: cafeInfo.latitude,
                    longitude: cafeInfo.longitude
                )
                marker.title = cafeInfo.name
                marker.icon = self.getCrowdedMarkerUIImage(crowded: cafeInfo.getMinCrowded())?.resizeImageTo(size: CGSize(width: markerHeight * 0.85, height: markerHeight))
                marker.isFlat = false
                marker.isDraggable = false
                marker.appearAnimation = GMSMarkerAnimation.pop
                marker.snippet = cafeInfo.getMinCrowded().toCrowded().string + "\n자세히보기 >"
                marker.groundAnchor = CGPoint(x: 0.5, y: 0.9)
                marker.userData = cafeInfo
                marker.map = mapView
            }
            return mapView
        case .master:
            cafeViewModel.cafeInfos.forEach { cafeInfo in

                let masterAvailableFloors = cafeInfo.masterAvailableFloors()
                var masterAvailableStateString = "현재 마스터 활동\n가능한 층이 없음"
                
                if !masterAvailableFloors.isEmpty {
                    masterAvailableStateString = "현재 "
                    masterAvailableFloors.enumerated().forEach { index, floor in
                        if index == masterAvailableFloors.count - 1 {
                            masterAvailableStateString += "\(floor.toFloor())"
                        } else {
                            masterAvailableStateString += "\(floor.toFloor()), "
                        }
                    }
                    masterAvailableStateString += "층\n"
                    masterAvailableStateString += "마스터 활동가능 >"
                }
                
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(
                    latitude: cafeInfo.latitude,
                    longitude: cafeInfo.longitude
                )
                marker.title = cafeInfo.name
                marker.icon = self.getMasterMarkerUIImage(available: cafeInfo.isMasterAvailable())?.resizeImageTo(size: CGSize(width: markerHeight * 0.85, height: markerHeight))
                marker.isFlat = false
                marker.isDraggable = false
                marker.appearAnimation = GMSMarkerAnimation.pop
                marker.snippet = masterAvailableStateString
                marker.groundAnchor = CGPoint(x: 0.5, y: 0.9)
                marker.userData = cafeInfo
                marker.map = mapView
            }
            return mapView
        }
    }
    
    
    class MapCoordinator: NSObject, GMSMapViewDelegate {
        
        let onMarkerTap: (CafeInfo) -> Void
        let onMarkerInfoWindowTap: () -> Void
        let parent: GoogleMapView
        
        init(parent: GoogleMapView, onMarkerTap: @escaping (CafeInfo) -> Void, onMarkerInfoWindowTap: @escaping () -> Void) {
            self.parent = parent
            self.onMarkerTap = onMarkerTap
            self.onMarkerInfoWindowTap = onMarkerInfoWindowTap
        }
            
        func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
            
            guard let markerCafeInfo = marker.userData as? CafeInfo
            else { return nil }

            onMarkerTap(markerCafeInfo)

            let cafeTitleLength = markerCafeInfo.name.count
            var infoWindowWidth = 10

            if (cafeTitleLength < 6) {
                infoWindowWidth = cafeTitleLength * 20
            } else if cafeTitleLength < 10 {
                infoWindowWidth = cafeTitleLength * 16
            } else {
                infoWindowWidth = cafeTitleLength * 12
            }
            
            return CustomMarkerInfoWindow(
                frame: CGRect(x: 0, y: 0, width: infoWindowWidth, height: 56),
                title: marker.title ?? "",
                subTitle: marker.snippet ?? ""
            )
        }
        
        func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
            onMarkerInfoWindowTap()
        }
    }
}

enum MapType {
    case crowded, master
}
