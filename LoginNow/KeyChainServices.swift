//
//  KeyChainServices.swift
//  LoginNow
//
//  Created by Martin Brunner on 14.02.15.
//  Copyright (c) 2015 Martin Brunner. All rights reserved.
//

import UIKit
import Security

// Identifiers
let servicePrivateKey = "privateKey"
let servicePassword = "password"
let userAccount = "authenticatedUser"
let accessGroup = "LoginNow"

class KeychainService: NSObject {
    
    /**
    * Exposed methods to perform queries.
    * Note: feel free to play around with the arguments
    * for these if you want to be able to customise the
    * service identifier, user accounts, access groups, etc.
    */
    class func saveToken(token: NSString, service: NSString) {
        self.save(service , data: token)
    }
    
    class func loadToken(service: NSString) -> NSString? {
        var token = self.load(service)
        
        return token
    }
    
    class func deleteKeyChainEntry(service: NSString) {
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, service, userAccount], forKeys: [kSecClass, kSecAttrService, kSecAttrAccount])
        
        // Delete any existing items
        var status: OSStatus = SecItemDelete(keychainQuery as CFDictionaryRef)
        if status != errSecSuccess {
            println("Error to delete item from keychain: \(status)")
        }

    }
    
    /**
    * Internal methods for querying the keychain.
    */
    private class func save(service: NSString, data: NSString) {
        var dataFromString: NSData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!

        // Instantiate a new default keychain query
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, service, userAccount, dataFromString], forKeys: [kSecClass, kSecAttrService, kSecAttrAccount, kSecValueData])
        
        // Delete any existing items
        var status: OSStatus = SecItemDelete(keychainQuery as CFDictionaryRef)
        if status != errSecSuccess {
            println("Error to delete item from keychain: \(status)")
        }
        
        // Add the new keychain item
         status = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
        if status != errSecSuccess {
            println("Error to add item to keychain: \(status)")
        }
    }
    
    private class func load(service: NSString) -> NSString? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, service, userAccount, kCFBooleanTrue, kSecMatchLimitOne], forKeys: [kSecClass, kSecAttrService, kSecAttrAccount, kSecReturnData, kSecMatchLimit])
        
        var dataTypeRef :Unmanaged<AnyObject>?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        
        let opaque = dataTypeRef?.toOpaque()
        
        var contentsOfKeychain: NSString?
        
        if let op = opaque {
            let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
            
            // Convert the data retrieved from the keychain into a string
            contentsOfKeychain = NSString(data: retrievedData, encoding: NSUTF8StringEncoding)

        } else {
            println("Nothing was retrieved from the keychain. Status code \(status)")
            return nil
        }
        if contentsOfKeychain?.length != 0 {
            return contentsOfKeychain
        }
        else {
            return nil
        }
    }
}
