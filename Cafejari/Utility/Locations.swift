//
//  Locations.swift
//  Cafejari
//
//  Created by 안용우 on 2022/12/21.
//

import Foundation
import GoogleMaps

struct Locations {
    let name: String
    let cameraPosition: GMSCameraPosition
}
        

extension Locations {
    static var sinchon = Locations(
        name: "신촌역",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.55649747287372,
            longitude: 126.93710302643744,
            zoom: Float.zoom.Default.rawValue
        )
    )
    static var hongik = Locations(
        name: "홍대입구역",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.557176,
            longitude: 126.924175,
            zoom: Float.zoom.Default.rawValue
        )
    )
    static var ewha = Locations(
        name: "이대역",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.557407,
            longitude: 126.945836,
            zoom: Float.zoom.Default.rawValue
        )
    )
    static var hyehwa = Locations(
        name: "혜화",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.582351,
            longitude: 127.001308,
            zoom: Float.zoom.Default.rawValue
        )
    )
    static var konkuk = Locations(
        name: "건대입구역",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.540778,
            longitude: 127.071034,
            zoom: Float.zoom.Default.rawValue
        )
    )
    static var wangsimni = Locations(
        name: "왕십리역",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.561233,
            longitude: 127.039957,
            zoom: Float.zoom.Default.rawValue
        )
    )
    static var anam = Locations(
        name: "안암(고려대)역",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.586277,
            longitude: 127.028590,
            zoom: Float.zoom.Default.rawValue
        )
    )
    static var heukseok = Locations(
        name: "흑석역",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.508567,
            longitude: 126.963309,
            zoom: Float.zoom.Default.rawValue
        )
    )
    static var seoulUniv = Locations(
        name: "서울대입구역",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.481423,
            longitude: 126.952701,
            zoom: Float.zoom.Default.rawValue
        )
    )
    static var sillim = Locations(
        name: "신림역",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.484744,
            longitude: 126.929578,
            zoom: Float.zoom.Default.rawValue
        )
    )
    static var foreignUniv = Locations(
        name: "외대앞역",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.595448,
            longitude: 127.059551,
            zoom: Float.zoom.Default.rawValue
        )
    )
    static var hoegi = Locations(
        name: "회기역",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.589647,
            longitude: 127.057347,
            zoom: Float.zoom.Default.rawValue
        )
    )
    static var kwangWoon = Locations(
        name: "광운대역",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.620769,
            longitude: 127.058921,
            zoom: Float.zoom.Default.rawValue
        )
    )
    static var noryangjin = Locations(
        name: "노량진역",
        cameraPosition: GMSCameraPosition.camera(
            withLatitude: 37.513058,
            longitude: 126.942192,
            zoom: Float.zoom.Default.rawValue
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
