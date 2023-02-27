//
//  AppDelegate.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/20.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKAuth
import GooglePlaces
import GoogleSignIn
import GoogleMobileAds
import FirebaseCore
import FirebaseMessaging
import FirebaseInAppMessaging
import FirebaseAnalytics

import AudioToolbox

class AppDelegate: NSObject, UIApplicationDelegate {
    
    @Inject private var tokenRepogitory: TokenRepository
    
    // 앱이 켜졌을때
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let googleMapApiKey = Bundle.main.infoDictionary?["GOOGLE_MAP_API_KEY"] ?? ""
        let kakaoNativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey as! String)

        // GooglePlace SDK 초기화
        GMSPlacesClient.provideAPIKey(googleMapApiKey as! String)

        // Firebase 초기화
        FirebaseApp.configure()

        // 원격 알림 델리겟 등록
        UNUserNotificationCenter.current().delegate = self

        // 메세징 델리겟 등록
        Messaging.messaging().delegate = self

        // GoogleAds 초기화
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["478444e6db8ce9170616526ac599c0cd"]

        application.registerForRemoteNotifications()
        
        return true
    }
    
    // fcm 토큰이 등록 되었을 때
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate : MessagingDelegate {

    // fcm 등록 토큰을 받았을 때
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        tokenRepogitory.saveFcmToken(fcmToken: fcmToken)
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {

    // 푸시메세지가 포그라운드 상태에서 나올때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        _ = notification.request.content.userInfo

        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        completionHandler([.banner, .list, .sound, .badge])
    }

    // 푸시메세지를 통해 앱을 켤때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        _ = response.notification.request.content.userInfo

        completionHandler()
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
      AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

      // Print full message.

      return UIBackgroundFetchResult.newData
    }
}
