//
//  MiniNaverMapView.swift
//  Cafejari
//
//  Created by 안용우 on 2023/01/23.
//

import SwiftUI
import NMapsMap

struct MiniNaverMapView: UIViewRepresentable {
    
    let cafeInfo: CafeInfo
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()
        view.showCompass = false
        view.showLocationButton = false
        view.showScaleBar = false
        view.showIndoorLevelPicker = false
        view.showZoomControls = false
        view.mapView.allowsRotating = false
        view.mapView.allowsScrolling = false
        view.mapView.allowsTilting = false
        view.mapView.allowsZooming = false
        view.mapView.isIndoorMapEnabled = false
        view.mapView.isRotateGestureEnabled = false
        view.mapView.isTiltGestureEnabled = false
        view.mapView.isZoomGestureEnabled = false
        view.mapView.isScrollGestureEnabled = false
        view.mapView.positionMode = .direction
        view.mapView.zoomLevel = Zoom.medium
        
        let marker = NMFMarker()
        marker.iconImage = NMFOverlayImage(name: cafeInfo.getMinCrowded().toCrowded().image)
        marker.position = NMGLatLng(lat: cafeInfo.latitude, lng: cafeInfo.longitude)
        marker.captionAligns = [.top]
        marker.height = 36.0
        marker.width = 31.0
        marker.captionOffset = 4.0
        marker.captionTextSize = 14.0
        marker.subCaptionTextSize = 13.0
        marker.captionText = cafeInfo.name
        marker.subCaptionText = cafeInfo.getMinCrowded().toCrowded().string
        marker.subCaptionColor = cafeInfo.getMinCrowded().toCrowded().uiTextColor
        marker.subCaptionHaloColor = cafeInfo.getMinCrowded().toCrowded().uiColor
        marker.mapView = view.mapView
        
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        
    }
}


