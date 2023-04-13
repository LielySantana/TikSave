//
//  KeyChainService.swift
//  TikSave
//
//  Created by Christina Santana on 15/3/23.
//

import Foundation
import KeychainSwift

fileprivate struct Keys{
    static let isPremium = "premium"
    static let isRated = "rated"
}

class KeychainService: NSObject {
    static let keychain = KeychainSwift(keyPrefix:"TikSaveKeyChain")

    static func clear(){
        keychain.clear()
    }
    
    
    static var isPremium: Bool {
        get {
            let premiumship = keychain.getBool(Keys.isPremium)
            if let premiumship = premiumship {
                if premiumship {
                    return true
                }
            }
            return false
        }
        set(newValue) {
            keychain.set(newValue, forKey: Keys.isPremium)
        }
    }
    
}
