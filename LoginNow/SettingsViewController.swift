//
//  SettingsViewController.swift
//  LoginNow
//
//  Created by Martin Brunner on 13.02.15.
//  Copyright (c) 2015 Martin Brunner. All rights reserved.
//

import UIKit

let kIntranetID = "intranetID"
let kIntranetPW = "intranetPW"
let kTimer = "timer"
let kDebugMode = "debugMode"
var pw:NSString = ""
let kAppVersion = "Version 0.95"


class SettingsViewController: UIViewController {
    
    @IBOutlet weak var IntranetIDTextField: UITextField!
    @IBOutlet weak var intranetPasswordTextField: UITextField!
    @IBOutlet weak var timerTextField: UITextField!
    @IBOutlet weak var debugSwitch: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSUserDefaults.standardUserDefaults().boolForKey(kLoadedOnceKey) == false {
            KeychainService.deleteKeyChainEntry(servicePassword)
            timerTextField.text = "100"
            debugSwitch.on = false
        }
        else {
            IntranetIDTextField.text = NSUserDefaults.standardUserDefaults().stringForKey(kIntranetID)
            intranetPasswordTextField.text = KeychainService.loadToken(servicePassword) as! String
            timerTextField.text = NSUserDefaults.standardUserDefaults().stringForKey(kTimer)
            debugSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(kDebugMode)
        }
        versionLabel.text = kAppVersion
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(true , forKey: kLoadedOnceKey)
        KeychainService.saveToken(intranetPasswordTextField.text, service: servicePassword)
        NSUserDefaults.standardUserDefaults().setObject(IntranetIDTextField.text, forKey: kIntranetID)
        if timerTextField.text.isEmpty || (timerTextField.text.toInt() < 100) {
            NSUserDefaults.standardUserDefaults().setObject("100", forKey: kTimer)
        }
        else {
            NSUserDefaults.standardUserDefaults().setObject(timerTextField.text, forKey: kTimer)
        }
        NSUserDefaults.standardUserDefaults().setBool(debugSwitch.on, forKey: kDebugMode)
        debugMode = debugSwitch.on
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}
