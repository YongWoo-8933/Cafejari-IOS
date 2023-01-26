//
//  NaverMapView.swift
//  Cafejari
//
//  Created by 안용우 on 2023/01/21.
//

import SwiftUI
import NMapsMap

struct NaverMapView: UIViewRepresentable {
    
    @Binding var markers: [NMFMarker]
    @Binding var animateToLongDistance: NMFCameraPosition?
    @Binding var animateToShortDistance: NMGLatLng?
    
    let startCameraPosition: NMFCameraPosition
    let closeMenu: () -> Void
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(closeMenu: closeMenu)
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
        view.mapView.moveCamera(NMFCameraUpdate(position: startCameraPosition))
        
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        
        self.markers.forEach { marker in
            marker.mapView = uiView.mapView
        }
        if let cameraPosition = self.animateToLongDistance {
            DispatchQueue.main.async {
                self.animateToLongDistance = nil
            }
            let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
            cameraUpdate.animation = .fly
            cameraUpdate.animationDuration = 1.5
            uiView.mapView.moveCamera(cameraUpdate)
        }
        if let latLng = animateToShortDistance {
            DispatchQueue.main.async {
                self.animateToShortDistance = nil
            }
            let cameraUpdate = NMFCameraUpdate(scrollTo: latLng)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.35
            uiView.mapView.moveCamera(cameraUpdate)
        }
    }
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate {
        
        let closeMenu: () -> Void
        
        init(closeMenu: @escaping () -> Void) {
            self.closeMenu = closeMenu
        }
        
        func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.closeMenu()
            }
        }
        
        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.closeMenu()
            }
        }

    }
}

