//
//  AppDelegate.swift
//  HamburgerMenuBlog
//
//  Created by Erica Millado on 7/15/17.
//  Copyright © 2017 Erica Millado. All rights reserved.
//

import UIKit
import UserNotifications
import OneSignal
//import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
//        FirebaseApp.configure()
        UINavigationBar.appearance().barTintColor = UIColor.init(hexString: "#a00000");
        UINavigationBar.appearance().tintColor = UIColor.white;
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "532b6453-edae-444a-b115-48d4273b867d",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })

        // Override point for customization after application launch.
        return true
    }
}
