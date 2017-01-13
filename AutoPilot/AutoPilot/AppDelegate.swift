//
//  AppDelegate.swift
//  AutoPilot
//
//  Created by Olivia Legge on 1/2/17.
//  Copyright © 2017 Olivia Legge. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var notificationCounter = 0
    var flightIsRunning = false
    var currentFlightSteps = [String]()
    var flightName = String(){
        didSet{
            notificationCounter = 0
        }
    }
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
            if !accepted {
                print("Notification access denied.")
            }
        }
        let nextAction = UNNotificationAction(identifier: "next", title: "Done!", options: [])
        let skipAction = UNNotificationAction(identifier: "skip", title: "Skip This Step", options: [])
        let endAction = UNNotificationAction(identifier: "end", title: "End This Flight", options: [])
        let category = UNNotificationCategory(identifier: "onFlightCategory", actions: [nextAction, skipAction, endAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        //Something like if there's an active list, schedule notification.
       
        print(">>>>>> BREADCRUMBS 2")
        if flightIsRunning && notificationCounter < currentFlightSteps.count {
            print(">>>>>> BREADCRUMBS 3")
            scheduleNotification()
            print(">>>>>> BREADCRUMBS 6")
            
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func scheduleNotification() {
        print(">>>>>> BREADCRUMBS 4")
        UNUserNotificationCenter.current().delegate = self
        
        // Fires 1 seconds after called
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        print(">>>>>> BREADCRUMBS 5")
        let content = UNMutableNotificationContent()
        content.title = flightName
        content.body = currentFlightSteps[notificationCounter]
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "onFlightCategory"
        
        
//        For a Picture -- But it doesn't work as is yet
//      In the tutorial, the photo is not in Assets.. try to rewrite this without the bundle main, maybe?
        
        if let path = Bundle.main.path(forResource: "defaultPhoto", ofType: "png") {
            let url = URL(fileURLWithPath: path)
            
            do {
                let attachment = try UNNotificationAttachment(identifier: "defaultPhoto", url: url, options: nil)
                content.attachments = [attachment]
            } catch {
                print("The attachment was not loaded.")
            }
        }
        
        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if notificationCounter >= (currentFlightSteps.count - 1 ){
            flightIsRunning = false
            return
        }
        if response.actionIdentifier == "next" {
            print("next was clicked")
            notificationCounter += 1
            scheduleNotification()
        } else if response.actionIdentifier == "skip" {
            notificationCounter += 1
            print("skip was clicked")
            scheduleNotification()
        } else if response.actionIdentifier == "end"{
            flightIsRunning = false
            print("end was clicked")
        }
    }
}

