//
//  WiFiNetwork.swift
//  LoginNow
//
//  Created by Martin Brunner on 13.02.15.
//  Copyright (c) 2015 Martin Brunner. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

class WiFiNetwork {
    var currentSSID = ""
    
    func getSSID() -> String? {
        
        if let interfaces = CNCopySupportedInterfaces() {
            let interfacesArray = interfaces.takeRetainedValue() as! [String]
            if interfacesArray.count > 0 {
                let interfaceName = interfacesArray[0] as String
                if let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName) {
                    let interfaceData = unsafeInterfaceData.takeRetainedValue() as Dictionary!
                    currentSSID = interfaceData["SSID"] as! String
                    return currentSSID
                    
                } else {
                    return nil
                }
            } else {
                return nil
            }
            
        } //
        else {
            return nil
        }
    }
    
    func isIBMVISITOR() -> Bool {
        if let ssID = self.getSSID() {
            if ssID == "IBMVISITOR" {
            return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
        
    }
    
}