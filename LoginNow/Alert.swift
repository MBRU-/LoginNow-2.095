//
//  Alert.swift
//  theClientsVoice
//
//  Created by Martin Brunner on 11.12.14.
//  Copyright (c) 2014 Martin Brunner. All rights reserved.
//

import UIKit

class Alert  {

    
    class func showAlertWithText (#viewController: UIViewController, header: String = "Warning", message: String) {
        var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
        
    }
    

}
