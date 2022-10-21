//
//  AppDelegate.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/20.
//

import Foundation
import GoogleMaps
import GooglePlaces

class AppDelegate: NSObject, UIApplicationDelegate    {
     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
         
         let googleMapApiKey = Bundle.main.infoDictionary?["GOOGLE_MAP_API_KEY"] ?? ""
         
         // GoogleMap SDK 초기화
         GMSServices.provideAPIKey(googleMapApiKey as! String)
         GMSServices.setMetalRendererEnabled(true)
         
         // GooglePlace SDK 초기화
         GMSPlacesClient.provideAPIKey(googleMapApiKey as! String)
         return true
     }
 }
