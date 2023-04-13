//
//  SharedService.swift
//  TikSave
//
//  Created by Christina Santana on 15/3/23.
//

import Foundation

struct SharedService {
    static var shared = SharedService()
    
    var isPremium: Bool {
        get {
            return KeychainService.isPremium
            //if let expirationDate = expirationDate {
            //   return KeychainService.isPremium && (expirationDate > Date())
            //}
            //return false
        }
        set(newValue) {
            KeychainService.isPremium = newValue
        }
    }
    
    var startDate: Date? {
        get {
            try? UserDefaults.standard.getObject(forKey: "startDate", castTo: Date.self)
        }
        set {
            try? UserDefaults.standard.setObject(newValue, forKey: "startDate")
        }
    }
    
    var expirationDate: Date? {
        get {
            try? UserDefaults.standard.getObject(forKey: "expirationDate", castTo: Date.self)
        }
        set {
            try? UserDefaults.standard.setObject(newValue, forKey: "expirationDate")
        }
    }
    
    var subscriptionType: SubscriptionType {
        get {
            var type = try? UserDefaults.standard.getObject(forKey: "subscriptionType", castTo: SubscriptionType.self)
            if let type = type {
                return type
            }
            if let start = startDate?.dateByAddingDays(days: 50), let end = expirationDate, start < end {
                return .yearly
            }
            return .monthly
        }
        set {
            try? UserDefaults.standard.setObject(newValue, forKey: "subscriptionType")
        }
    }
}
