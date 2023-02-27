//
//  NaverNewMapView.swift
//  Cafejari
//
//  Created by 안용우 on 2023/02/24.
//

import SwiftUI
import NMapsMap

struct NaverMapView: UIViewRepresentable {
    
    @Binding var markers: [NMFMarker]
    @Binding var isMarkerUpdateTriggered: Bool
    
    @Binding var cameraPosition: NMFCameraPosition
    @Binding var isLongDCameraUpdateTriggered: Bool
    @Binding var isShortDCameraUpdateTriggered: Bool
    
    let startCameraPosition: NMFCameraPosition
    let closeMenu: () -> Void
    let onCameraPositionChanged: (NMFCameraPosition) -> Void
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            parent: self,
            closeMenu: closeMenu,
            onCameraPositionChanged: onCameraPositionChanged
        )
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()
        view.showCompass = false
        view.showLocationButton = false
        view.showScaleBar = false
        view.showIndoorLevelPicker = false
        view.showZoomControls = false
        view.mapView.allowsRotating = true
        view.mapView.allowsScrolling = true
        view.mapView.allowsTilting = false
        view.mapView.allowsZooming = true
        view.mapView.animationDuration = 1.5
        view.mapView.extent = Locations.koreaBoundary
        view.mapView.isIndoorMapEnabled = false
        view.mapView.isRotateGestureEnabled = true
        view.mapView.isStopGestureEnabled = true
        view.mapView.isTiltGestureEnabled = false
        view.mapView.isZoomGestureEnabled = true
        view.mapView.isScrollGestureEnabled = true
        view.mapView.maxZoomLevel = 20.0
        view.mapView.minZoomLevel = 6.0
        view.mapView.positionMode = .normal
        view.mapView.symbolScale = 0.75
        view.mapView.zoomLevel = Zoom.medium
        view.mapView.addCameraDelegate(delegate: context.coordinator)
        view.mapView.touchDelegate = context.coordinator
        onCameraPositionChanged(startCameraPosition)
        view.mapView.moveCamera(NMFCameraUpdate(position: startCameraPosition))
        
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        
        if isMarkerUpdateTriggered && !context.coordinator.isMarkerUpdateProgress {
            self.markers.forEach { marker in
                marker.mapView = uiView.mapView
            }
            
            context.coordinator.isMarkerUpdateProgress = true
            
            DispatchQueue.main.async {
                self.isMarkerUpdateTriggered = false
                context.coordinator.isMarkerUpdateProgress = false
            }
        }
        
        if isLongDCameraUpdateTriggered && !context.coordinator.isCameraUpdateAnimationProgress{
            let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
            cameraUpdate.animation = .fly
            cameraUpdate.animationDuration = 1.4
            uiView.mapView.moveCamera(cameraUpdate)
            
            context.coordinator.isCameraUpdateAnimationProgress = true
            
            DispatchQueue.main.async {
                self.isLongDCameraUpdateTriggered = false
                context.coordinator.isCameraUpdateAnimationProgress = false
            }
        }
        
        if isShortDCameraUpdateTriggered && !context.coordinator.isCameraUpdateAnimationProgress{
            let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.45
            uiView.mapView.moveCamera(cameraUpdate)
            
            context.coordinator.isCameraUpdateAnimationProgress = true
            
            DispatchQueue.main.async {
                self.isShortDCameraUpdateTriggered = false
                context.coordinator.isCameraUpdateAnimationProgress = false
            }
        }
    }
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
        
        let parent: NaverMapView
        let closeMenu: () -> Void
        let onCameraPositionChanged: (NMFCameraPosition) -> Void
        
        var isCameraUpdateAnimationProgress: Bool = false
        var isMarkerUpdateProgress: Bool = false
        var isUserMoveCameraPosition: Bool = false
        
        init(
            parent: NaverMapView,
            closeMenu: @escaping () -> Void,
            onCameraPositionChanged: @escaping (NMFCameraPosition) -> Void
        ) {
            self.parent = parent
            self.closeMenu = closeMenu
            self.onCameraPositionChanged = onCameraPositionChanged
        }
        
        func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
            DispatchQueue.main.async {
                self.closeMenu()
            }
        }
        
        func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
            self.onCameraPositionChanged(mapView.cameraPosition)
        }
        
        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            DispatchQueue.main.async {
                self.closeMenu()
            }
        }
    }
}
