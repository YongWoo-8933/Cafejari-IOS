//
//  Locations.swift
//  Cafejari
//
//  Created by 안용우 on 2022/12/21.
//

import Foundation
import NMapsMap

struct Locations {
    let name: String
    let cameraPosition: NMFCameraPosition
}

extension Locations {
    static var koreaBoundary = NMGLatLngBounds(
        southWest: NMGLatLng(lat: 32.724435, lng: 125.469936),
        northEast: NMGLatLng(lat: 38.447639, lng: 131.995789)
    )
    static var sinchon = Locations(
        name: "신촌역",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.55649747287372, lng: 126.93710302643744),
            zoom: Zoom.medium
        )
    )
    static var hongik = Locations(
        name: "홍대입구역",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.557176, lng: 126.924175),
            zoom: Zoom.medium
        )
    )
    static var ewha = Locations(
        name: "이대역",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.557407, lng: 126.945836),
            zoom: Zoom.medium
        )
    )
    static var hyehwa = Locations(
        name: "혜화",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.582351, lng: 127.001308),
            zoom: Zoom.medium
        )
    )
    static var konkuk = Locations(
        name: "건대입구역",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.540778, lng: 127.071034),
            zoom: Zoom.medium
        )
    )
    static var wangsimni = Locations(
        name: "왕십리역",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.561233, lng: 127.039957),
            zoom: Zoom.medium
        )
    )
    static var anam = Locations(
        name: "안암(고려대)역",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.586277, lng: 127.028590),
            zoom: Zoom.medium
        )
    )
    static var heukseok = Locations(
        name: "흑석역",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.508567, lng: 126.963309),
            zoom: Zoom.medium
        )
    )
    static var seoulUniv = Locations(
        name: "서울대입구역",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.481423, lng: 126.952701),
            zoom: Zoom.medium
        )
    )
    static var sillim = Locations(
        name: "신림역",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.484744, lng: 126.929578),
            zoom: Zoom.medium
        )
    )
    static var foreignUniv = Locations(
        name: "외대앞역",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.595448, lng: 127.059551),
            zoom: Zoom.medium
        )
    )
    static var hoegi = Locations(
        name: "회기역",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.589647, lng: 127.057347),
            zoom: Zoom.medium
        )
    )
    static var kwangWoon = Locations(
        name: "광운대역",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.620769, lng: 127.058921),
            zoom: Zoom.medium
        )
    )
    static var noryangjin = Locations(
        name: "노량진역",
        cameraPosition: NMFCameraPosition(
            NMGLatLng(lat: 37.513058, lng: 126.942192),
            zoom: Zoom.medium
        )
    )
    
    static var locationList = [
        kwangWoon,
        konkuk,
//        noryangjin,
//        seoulUniv,
//        sillim,
        sinchon,
//        anam,
//        wangsimni,
//        foreignUniv,
        ewha,
        hyehwa,
        hongik,
//        hoegi,
//        heukseok,
    ]
}
