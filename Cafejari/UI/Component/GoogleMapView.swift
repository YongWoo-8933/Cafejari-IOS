//
//  GoogleMapView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/20.
//

import SwiftUI
import GoogleMaps

struct GoogleMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.sinchon
        let mapView = GMSMapView(frame: CGRect.zero, camera: camera)
        let markerHeight = 35
        
        // 기본설정
        mapView.isIndoorEnabled = true
        mapView.isTrafficEnabled = false
        mapView.isMyLocationEnabled = true
        mapView.accessibilityElementsHidden = false
        mapView.isBuildingsEnabled = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: 37.55649747287372,
            longitude: 126.93710302643744
        )
        marker.title = "신촌"
        marker.appearAnimation = .pop
        marker.isFlat = false
        marker.isDraggable = false
        marker.snippet = "혼잡"
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.icon = UIImage(named: "crowded_marker_3")
        marker.setIconSize(scaledToSize: .init(width: Int( Double(markerHeight) * 0.85 ), height: markerHeight))
        marker.map = mapView
        
        return mapView
    }
         
     func updateUIView(_ uiView: GMSMapView, context: Context) {
         
     }
}

struct GoogleMapView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleMapView()
    }
}
