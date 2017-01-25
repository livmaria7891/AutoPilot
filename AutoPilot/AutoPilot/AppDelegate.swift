//
//  AppDelegate.swift
//  AutoPilot
//
//  Created by Olivia Legge on 1/2/17.
//  Copyright © 2017 Olivia Legge. All rights reserved.
//

import UIKit
import UserNotifications
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var flight: Flight? { didSet {
        notificationCounter = 0
        if flight != nil {
            currentFlightSteps = (flight?.steps)!
            flightName = (flight?.name)!
            avgTime = (flight?.avgTime)!
        }
        }
    }

    var notificationCounter = 0
    var flightIsRunning = false
    var currentFlightSteps = [String]()
    var flightName = String()
    var suppliesString: String?
    var avgTime = Double()
    
    // Time Tracking Variables
    var startTime = Date()
    
    // Variables to enable Saving
    
    var flights = [[Flight]]()
    var path = IndexPath()
    var myViewController = CreateViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // App Styles
        // nav bar
        let navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.tintColor = UIColor(netHex:0x485A7A)
        navigationBarAppearance.barTintColor = UIColor(netHex:0x485A7A)
        navigationBarAppearance.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "norwester", size: 26)!, NSForegroundColorAttributeName: UIColor(netHex: 0xFAFAFA)
        ]
        
        
        let itemButtonAppearance = UIBarButtonItem.appearance()
        let customButtonFont = UIFont(name: "Montserrat-Light", size: 17.0)
        itemButtonAppearance.tintColor = UIColor(netHex:0xFAFAFA)
        itemButtonAppearance.setTitleTextAttributes([NSFontAttributeName: customButtonFont!], for: UIControlState.normal)
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
            if !accepted {
                print("Notification access denied.")
            }
        }
        let nextAction = UNNotificationAction(identifier: "next", title: "Done!", options: [])
        let skipAction = UNNotificationAction(identifier: "skip", title: "Skip This Step", options: [])
        let endAction = UNNotificationAction(identifier: "end", title: "End This Flight", options: [])
        let continueAction = UNNotificationAction(identifier: "continue", title: "Got It", options: [])
        let category1 = UNNotificationCategory(identifier: "onFlightCategory", actions: [nextAction, skipAction, endAction], intentIdentifiers: [], options: [])
        let category2 = UNNotificationCategory(identifier: "flightCompletedCategory", actions: [], intentIdentifiers: [], options: [])
        let category3 = UNNotificationCategory(identifier: "genericNotificationCategory", actions: [continueAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category1, category2, category3])
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        //Something like if there's an active list, schedule notification.

        if flightIsRunning && notificationCounter < currentFlightSteps.count {
            
            
            // If there are supplies, send notification
            if suppliesString != nil {
                scheduleSuppliesNotification(message: suppliesString!)
            } else {
                scheduleNotification()
            }
            
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
        
        UNUserNotificationCenter.current().delegate = self
        
        // Fires 1 seconds after called
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = flightName
        content.body = currentFlightSteps[notificationCounter]
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "onFlightCategory"
        
        
//        For a Picture -- But it doesn't work as is yet
//      In the tutorial, the photo is not in Assets.. try to rewrite this without the bundle main, maybe?
        
//        if let path = Bundle.main.path(forResource: "defaultPhoto", ofType: "png") {
//            let url = URL(fileURLWithPath: path)
//            
//            do {
//                let attachment = try UNNotificationAttachment(identifier: "defaultPhoto", url: url, options: nil)
//                content.attachments = [attachment]
//            } catch {
//                print("The attachment was not loaded.")
//            }
//        }
        
        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    
    func scheduleSuppliesNotification(message: String = "No supplies needed for this one! (Click Got It to continue)"){
        
        UNUserNotificationCenter.current().delegate = self
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = flightName
        content.body = message
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "genericNotificationCategory"
        
        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    
    func sendCompletedNotification(){
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = flightName
        content.body = "Congratulations! You finished \"\(flightName)\"!!"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "flightCompletedCategory"
        
        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    
    func saveFlight() {
        let thisFlight = prepareFlight()
        print(thisFlight)
        flights[path.section][path.row] = thisFlight
        print(flights)
        if (flight != nil) {
 
            let flightsFlattened = Array(flights.joined())
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(flightsFlattened, toFile: Flight.ArchiveURL.path)
            
            if isSuccessfulSave {
                os_log("Flights successfully saved.", log: OSLog.default, type: .debug)
            } else {
                os_log("Failed to save flights...", log: OSLog.default, type: .error)
            }
        }
    }
    
    func prepareFlight() -> Flight {
        let name = flightName
        let steps = flight?.steps
        let supplies = flight?.supplies
        let isFavorite = flight?.isFavorite
        let avgTime = self.avgTime
        
        let readyFlight = Flight(name: name, steps: steps, supplies: supplies, isFavorite: isFavorite!, avgTime: avgTime )
        self.myViewController.flight = readyFlight
        return readyFlight!
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == "continue" {
            scheduleNotification()
        }
        
        if notificationCounter >= (currentFlightSteps.count - 1 ){
            flightIsRunning = false
            let endTime = NSDate()

            avgTime = (flight?.setAverageTime(start: startTime, end: endTime as Date))!
            print(">>>>>>")
            print(flight?.avgTime ?? "No Flight")
            saveFlight()
            sendCompletedNotification()
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

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}


