//
//  Utility.swift
//  FollowTok
//
//  Created by krunal on 3/28/20.
//  Copyright © 2020 krunal. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications


var totalPoints = 500
@available(iOS 15.0, *)
let appDel = UIApplication.shared.delegate as! AppDelegate

let primaryColor = UIColor(named: "PrimaryColor")

func showAlert(title:String,msg:String,vc:UIViewController){
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
    }
    alert.addAction(okAction)
    vc.present(alert, animated: true, completion: nil)
}

func setPoints(vc:UIViewController){
    
    let pointDisplayLbl = UIBarButtonItem(title: "Points", style: .plain, target: nil, action: nil)
    vc.navigationItem.leftBarButtonItem = pointDisplayLbl

    
    let coinImg = UIBarButtonItem(customView: UIImageView(image: UIImage(named: "doll")))
    
    let pointLbl = UIBarButtonItem(title: "\(totalPoints)", style: .plain, target: vc, action: nil)
    
    let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    space.width = 0
    
    vc.navigationItem.rightBarButtonItems = [coinImg,space,pointLbl]
    
}

func combineDateAndTime(datePicker: UIDatePicker, timePicker: UIDatePicker) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd,yyyy"
    dateFormatter.timeZone = TimeZone.current // Set the time zone to the local time zone
    let date = dateFormatter.string(from: datePicker.date)
    
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "hh:mm a"
    timeFormatter.timeZone = TimeZone.current // Set the time zone to the local time zone
    let time = timeFormatter.string(from: timePicker.date)
    
    let dateString = "\(date), \(time)"
    
    let combinedFormatter = DateFormatter()
    combinedFormatter.dateFormat = "MMM dd,yyyy, hh:mm a"
    combinedFormatter.timeZone = TimeZone.current // Set the time zone to the local time zone
    let combinedDate = combinedFormatter.date(from: dateString)!
    
    return combinedDate
}


func substracHours(_ hours: Int, toDate date: Date) -> Date? {
    let calendar = Calendar.current
    var dateComponents = DateComponents()
    dateComponents.hour = -hours
    return calendar.date(byAdding: dateComponents, to: date)
}



class MyNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    // Implement the method to handle notifications received while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  willPresent notification: UNNotification,
                                  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Check that the app is not in the foreground
        guard UIApplication.shared.applicationState != .active else {
            completionHandler([])
            return
        }
        
        // If the app is not in the foreground, show the notification as an alert
        completionHandler([.alert, .sound])
    }
}





