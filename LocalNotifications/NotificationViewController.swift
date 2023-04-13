//
//  NotificationViewController.swift
//  LocalNotifications
//
//  Created by Christina Santana on 13/4/23.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    @IBOutlet var dismissButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        self.label?.text = content.body
    }
    
    @IBAction func dismissNotification() {
        extensionContext?.dismissNotificationContentExtension()
    }

}
