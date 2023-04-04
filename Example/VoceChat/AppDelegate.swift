//
//  AppDelegate.swift
//  VoceChat
//
//  Created by 范东同学 on 12/04/2022.
//  Copyright (c) 2022 范东同学. All rights reserved.
//

import UIKit
import VoceChat
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared().isEnabled = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
            //do register
        }
        VCManager.shared.register(serverUrl: .ServerURL)
        if VCManager.shared.isLogin() {
            //自动登录
            VCManager.shared.autoLogin { result in
                //do nothing
                debugPrint("推送用户ID:\(VCManager.shared.currentUser()?.user.uid ?? 0)")
                JPUSHService.setAlias("\(VCManager.shared.currentUser()?.user.uid ?? 0)", completion: { iResCode, iAlias, seq in
                    debugPrint("设置Alias code:\(iResCode)")
                }, seq: Int(Date().timeIntervalSince1970))
            } failure: { error in
                //do nothing
            }
            let tabC = TabBarController()
            self.window?.rootViewController = tabC
        }
        let entity = JPUSHRegisterEntity()
        entity.types = Int(JPAuthorizationOptions.alert.rawValue)|Int(JPAuthorizationOptions.badge.rawValue)|Int(JPAuthorizationOptions.sound.rawValue)|Int(JPAuthorizationOptions.providesAppNotificationSettings.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        JPUSHService.setup(withOption: launchOptions, appKey: "84f0e00d63e627662d2d7734", channel: "AppStore", apsForProduction: false)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        VCManager.shared.setDeviceToken(device_token: deviceToken) {
            //do nothing
        } failure: { error in
            //
        }
        JPUSHService.registerDeviceToken(deviceToken)
    }


}

extension AppDelegate: JPUSHRegisterDelegate{
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(.newData)
    }
    
    func jpushNotificationAuthorization(_ status: JPAuthorizationStatus, withInfo info: [AnyHashable : Any]!) {
        
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        if notification.request.trigger?.isKind(of: UNPushNotificationTrigger.classForCoder()) ?? false {
            JPUSHService.handleRemoteNotification(notification.request.content.userInfo)
        }
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        if response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.classForCoder()) ?? false {
            JPUSHService.handleRemoteNotification(response.notification.request.content.userInfo)
        }
        completionHandler()
        //如果消息里有URL，打开URL
        let userinfo = response.notification.request.content.userInfo
        guard let url = userinfo["url"] as? String else { return }
        if UIApplication.shared.canOpenURL(URL(string: url)!) {
            UIApplication.shared.open(URL(string: url)!)
        }
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification!) {
        if notification.request.trigger?.isKind(of: UNPushNotificationTrigger.classForCoder()) ?? false {
            //通知页面直接进入应用
        }else{
            //通知设置页面直接进入应用
        }
    }
    
    
}
