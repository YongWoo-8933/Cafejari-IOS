//
//  MiniGoogleMapView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/12.
//

import SwiftUI
import GoogleMaps

struct MiniGoogleMapView: UIViewRepresentable {
    
    @EnvironmentObject var cafeViewModel: CafeViewModel
    @EnvironmentObject var coreState: CoreState
    
    func makeUIView(context: Context) -> GMSMapView {
        
        let startCameraPosition = GMSCameraPosition.camera(
            withLatitude: coreState.userLastLocation?.coordinate.latitude ?? Locations.sinchon.cameraPosition.target.latitude,
            longitude: coreState.userLastLocation?.coordinate.longitude ?? Locations.sinchon.cameraPosition.target.longitude,
            zoom: Float.zoom.Large.rawValue
        )
        
        let mapView = GMSMapView(frame: CGRect.zero, camera: startCameraPosition)
        
        // 기본설정
        mapView.isIndoorEnabled = true
        mapView.isTrafficEnabled = false
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.tiltGestures = false
        mapView.accessibilityElementsHidden = true
        mapView.isBuildingsEnabled = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: coreState.masterRoomCafeLog.latitude,
            longitude: coreState.masterRoomCafeLog.longitude
        )
        marker.title = coreState.masterRoomCafeLog.name
        marker.isFlat = false
        marker.isDraggable = false
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.9)
        marker.map = mapView
        
        return mapView
    }
         
     func updateUIView(_ uiView: GMSMapView, context: Context) {
         
     }
}

