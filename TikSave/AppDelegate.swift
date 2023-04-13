//
//  AppDelegate.swift
//  TikSave
//
//  Created by krunal on 19/02/23.
//

import UIKit
import UserNotifications

@available(iOS 15.0, *)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let center = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
       
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor.white
            ]
            navigationBarAppearance.backgroundColor = UIColor.clear
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            
            let tabBarApperance = UITabBarAppearance()
            tabBarApperance.configureWithOpaqueBackground()
            tabBarApperance.backgroundColor = UIColor.clear
            UITabBar.appearance().scrollEdgeAppearance = tabBarApperance
            UITabBar.appearance().standardAppearance = tabBarApperance
        
//
//        StoreKitManager.shared.loadManager()
      
        
        
            

        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Came back!!!!!")
        NotificationCenter.default.post(name: Notification.Name("foreground"), object: nil)
    }
    
}

