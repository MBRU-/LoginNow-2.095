//
//  ViewController.swift
//  LoginNow
//
//  Created by Martin Brunner on 29.01.15.
//  Copyright (c) 2015 Martin Brunner. All rights reserved.
//

import Foundation
import UIKit


let kLoadedOnceKey = "kLoadedOnceKeyValue"
var debugMode = false

class ViewController: UIViewController, NSURLSessionDelegate,NSURLSessionTaskDelegate, DoLogonDelegate {
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var copyDebugContext: UIBarButtonItem!
    
    var parseURL:String = ""
    var parseToken:NSString = ""
    
    var session = NSURLSession()
    let myWiFi = WiFiNetwork()
    var logonTimer: NSTimer?
    
    override func viewDidAppear(animated: Bool) {
        copyDebugContext.enabled = debugMode
  //      doLogon(isTimer: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        //If the app is run for the first time, we need to clear out previously stored password from keychain and call the settings dialog for credential entry
        if NSUserDefaults.standardUserDefaults().boolForKey(kLoadedOnceKey) == false {
            //  KeychainService.deleteKeyChainEntry(servicePassword)
            performSegueWithIdentifier("userCredentialSegue", sender: self)
        }
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.allowsCellularAccess = false
        sessionConfig.timeoutIntervalForRequest = 30.0;
        sessionConfig.timeoutIntervalForResource = 60.0;
        sessionConfig.HTTPMaximumConnectionsPerHost = 4;
        sessionConfig.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Never
        session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        session.resetWithCompletionHandler({})
        loginButton.backgroundColor = UIColor.redColor()
        debugMode = NSUserDefaults.standardUserDefaults().boolForKey(kDebugMode)
        //        debugMode ? (textField.text = "Debug ON\n") : (textField.text = "Debug OFF\n")
        
        loginButton.layer.cornerRadius = 10.0
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition,
        NSURLCredential!) -> Void) {
            completionHandler(
                NSURLSessionAuthChallengeDisposition.UseCredential,
                NSURLCredential(forTrust: challenge.protectionSpace.serverTrust))
            println("Call for Challenge")
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void) {
        var newRequest : NSURLRequest? = request
        println("HTTP REDIRECT called:main \(newRequest?.mainDocumentURL) \n redirect URL: \(newRequest?.URL) \n Method: \(newRequest?.HTTPMethod)\n\n")
        if let parseURLx:String = newRequest?.URL!.absoluteString {
            Alert.showAlertWithText(viewController: self, header: "Redirected to", message: parseURLx)
            if debugMode {
                textField.text = textField.text + "2 Redirected to \(parseURLx)\n"
            }
            //            prepareURLRequest(parseURLx)
            parseURL = parseURLx
        }
        
        completionHandler(newRequest)
    }
    
    @IBAction func copyDebugTextToClipboard(sender: UIBarButtonItem) {
        textField.selectAll(self)
        textField.copy(self)
        Alert.showAlertWithText(viewController: self, header: "Debug message", message: "The debug context has been copied.")
        textField.text = "The debug context has been copied to the clipboard. Please paste it into an eMail."
    }
    
    @IBAction func getURLstring(sender: UIButton) {
        self.loginButton.backgroundColor = UIColor.redColor()
        doLogon(isTimer: false)
    }
    
    //Fuction called by setTimer() and getURLstring()
    func doLogon(#isTimer: Bool) -> Bool {
        //  parseURL = "http://localhost/~mbru/myIframe01.html"
        //        parseURL = "http://localhost/~mbru/info.php"
        //                  parseURL = "https://google.com"
        parseURL = "http://afoto.ch"
        
        println("Called by timer")
        
        textField.text = ""
        if myWiFi.isIBMVISITOR() == true {  //must be set to true
            self.loginButton.backgroundColor = UIColor.redColor()
            textField.text = "Now trying to login to IBMVISITOR... \n\n"
            println("IBMVISITOR detected")
            println("\n1 prepareURLRequest called with URL \(parseURL)\n")
            session.resetWithCompletionHandler({})
            prepareURLRequest()
            if isTimer {
                    NSThread.sleepForTimeInterval(5.0)
            }

            return true
        }
        else {
            self.loginButton.backgroundColor = UIColor.redColor()
            if let currentWiFi = myWiFi.getSSID() {
                textField.text = "I don't see the IBMVISITOR WLAN\n Please connect to IBMVISITOR WLAN first\nCurrent SSID is: <\(currentWiFi)> "
            }
            else {
                textField.text = "I don't see the IBMVISITOR WLAN\n Please connect to IBMVISITOR WLAN first\nCurrent SSID is: <none> "
            }
            return false
        }
        
    }
    
    
    //Login request for IBM normal WiFi access (non Research)
    func sendLoginRequest () -> Bool {
        println("URL \(parseURL)")
        var password = ""
        var intranetID = ""
        
        if let pwd = KeychainService.loadToken(servicePassword) {
            password = pwd as String
            if let uid = NSUserDefaults.standardUserDefaults().stringForKey(kIntranetID){
                intranetID = uid
            }
        }
        else {
            return false
        }
        
        println("1 UID: \(intranetID)   1 PWD: \(password)\n\n")
        
        var request = NSMutableURLRequest(URL: NSURL(string: parseURL)!)
        request.HTTPMethod = "POST"
        var params = ""
        params = "au_pxytimetag=\(parseToken)&consent_status=accept&uname=\(intranetID)&pwd=\(password)&ok=OK"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            var stringData = NSString(data: data, encoding: NSASCIIStringEncoding)
            if let error = err  {
                if debugMode {
                    self.textField.text = self.textField.text + "\nError in <sendLoginRequest>:\n \(error.code)  \n \(error.domain)\n \(error.description)"
                }
                println("Error: \(error.code )")
                println("Error: \(error.domain )")
                let userInfo:NSDictionary = NSDictionary(dictionary: error.userInfo!)
                for str in userInfo  {
                    println("Error: \(str )")
                }
                
            }
            else {
                if debugMode {
                    self.textField.text = self.textField.text + "\n<sendLoginRequest> called with data:\n \(stringData)"
                }
                
                println("StringData: \(stringData)")
                if let str = self.parse(stringData!, open: "Authentication Successful", close: "!<") {
                    if let ssID  = self.myWiFi.getSSID() {
                        self.textField.text = self.textField.text + "Authentication SUCCESSFUL <\(ssID)>"
                        self.loginButton.backgroundColor = UIColor.greenColor()
                        self.parseURL = "http://afoto.ch"
                    }
                    
                }
                else {
                    self.loginButton.backgroundColor = UIColor.redColor()
                    self.textField.text = self.textField.text + "ERROR: Authentication failed"
                    
                }
            }
            
        })
        task.resume()
        return true
    }
    
    //Login request for Research WiFi access (using JAVAX client)
    func sendLoginRequestLAB () -> Bool {
        println("1 URL \(parseURL)")
        var password = ""
        var intranetID = ""
        
        if let pwd = KeychainService.loadToken(servicePassword) {
            password = pwd as String
            if let uid = NSUserDefaults.standardUserDefaults().stringForKey(kIntranetID){
                intranetID = uid
            }
        }
        else {
            return false
        }
        
        println("2 UID: \(intranetID)   2 PWD: \(password)\n\n")
        
        var request = NSMutableURLRequest(URL: NSURL(string: parseURL)!)
        request.HTTPMethod = "POST"
        var params = ""
        
        params = "form1=form1&form1%3Atext2=\(intranetID)&form1%3Asecret1=\(password)&form1%3Acheckbox1=on&form1%3Abutton1=Submit&javax.faces.ViewState=j_id1%3Aj_id2"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            var stringData = NSString(data: data, encoding: NSASCIIStringEncoding)
            if let error = err  {
                if debugMode {
                    self.textField.text = self.textField.text + "Error in <sendLoginRequestLAB>: \(error.code)  \n \(error.domain)\n \(error.description)"
                }
                println("Error: \(error.code )")
                println("Error: \(error.domain )")
                let userInfo:NSDictionary = NSDictionary(dictionary: error.userInfo!)
                for str in userInfo  {
                    println("Error: \(str )")
                }
            }
            else {
                if debugMode {
                    self.textField.text = self.textField.text + "\n<sendLoginRequestLAB> called with data:\n \(stringData)"
                }
                
                println("3 StringData: \(stringData)")
                
                if let str = self.parse(stringData!, open: "ihome", close: "faces") {
                    if let ssID  = self.myWiFi.getSSID() {
                        self.textField.text = self.textField.text + "Authentication SUCCESSFUL <\(ssID)>"
                        self.loginButton.backgroundColor = UIColor.greenColor()
                        self.parseURL = "http://afoto.ch"
                    }
                }
                else {
                    self.loginButton.backgroundColor = UIColor.redColor()
                    self.textField.text = self.textField.text + "ERROR: Authentication Failed"
                }
            }
        })
        task.resume()
        return true
    }
    
    
    
    func prepareURLRequest() {
        
        let url = parseURL  //parseURL is set in <prepareURLRequest>. In case of a redirection it gets overwritten in
        // <willPerformHTTPRedirection>
        
        var request = NSMutableURLRequest(URL: NSURL(string: url )!)
        var params = ""
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            println("\n44 prepareURLRequest called with URL \(url)\n")
            if debugMode {
                self.textField.text = self.textField.text + "\n44 <prepareURLRequest> called with URL \(url)\n"
            }
            self.doURLRequest(data, theResponse: response, theError: error)
            
        })
        task.resume()
    }
    
    func doURLRequest(theData: NSData?, theResponse: NSURLResponse?, theError: NSError?)  {
        var stringData = ""
        if let strData = NSString(data: theData!, encoding: NSASCIIStringEncoding) {
            stringData = strData as String
        }
        if debugMode {
            self.textField.text = self.textField.text + "\n<doURLRequest> called with data:\n \(stringData)>"
        }
        
        //    println("\n\n99 URL request with data: \(stringData)")
        if let error = theError  {
            self.textField.text = self.textField.text + "Error: <doURLRequest> \(error.code)  \n \(error.domain)\n \(error.description)"
            println("Error: \(error.code )")
            println("Error: \(error.domain )")
            let userInfo:NSDictionary = NSDictionary(dictionary: error.userInfo!)
            for str in userInfo  {
                println("Error: \(str )")
            }
            return
        }
        
        println("\n1 Success - Response: \n\(theResponse?.description)")
        //           println("\n\nStringData: \(stringData)")
        
        //check if response from Research WiFi environment using JAVAX
        if let parseString = parse( stringData,  open: "ilogon", close: "faces"){
            if debugMode {
                self.textField.text = self.textField.text + "\n11 Calling Login at LAB WIFI\n"
            }
            if  sendLoginRequestLAB()  == true {
                println("\n11 Calling Login at LAB WIFI")
            }
            return
        }
        
        if let newURL = extractURLfromBody(stringData) {       // is there an IFRAME hiding the redir address?
            println("\n3 prepareURLRequest called with URL \(newURL)\n")
            if debugMode {
                self.textField.text = self.textField.text + "\n 33 <parseIFRAME> called with URL \(newURL)\nn"
            }
            
            parseIFRAME(newURL as String)
        }
        
        //already loged in
        
        if let parseString = self.parse( stringData,  open: "ontent=\"Arch", close: ">") {
            println("\nNo need to login")
            println("\nWiFi OK: \(parseString) ")
            //                       println("Parsed: \(stringData) ")
            if let ssID = self.myWiFi.getSSID() {
                self.textField.text =  "\nWiFi access <\(ssID)> OK "
                self.loginButton.backgroundColor = UIColor.greenColor()
            }
            
        }
        else {
            self.loginButton.backgroundColor = UIColor.redColor()
        }
        return
    }
    
    func parseIFRAME(url: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: url )!)
        var params = ""
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            println("\n54 parseIFRAME called with URL \(url)\n")
            if debugMode {
                self.textField.text = self.textField.text + "\n54 <parseIFRAME> called with URL \(url)\n"
            }
            var stringData = ""
            if let strData = NSString(data: data!, encoding: NSASCIIStringEncoding) {
                stringData = strData as String
            }
            if debugMode {
                self.textField.text = self.textField.text + "\n55 <parseIFRAME> called with data:\n \(stringData)>"
            }
            
            //Parse the content of the iFRAME
            if let parseString = self.parse( stringData,  open: "post action=\"", close: "\"") {
                println("\n\nParsed URL: \(parseString) ")
                self.parseURL = parseString as String
                
                if let parseString = self.parse( stringData,  open: "au_pxytimetag value=\"", close: "\">") {
                    println("Parsed Token: \(parseString) \n")
                    self.parseToken = parseString
                    self.textField.text = "\(self.textField.text)\n" + "TAG: \(parseString) \n"
                    
                    self.textField.text = self.textField.text + "\nNow sending login credentials... "
                    if debugMode {
                        self.textField.text = self.textField.text + "\n60 Calling Login at IBM WIFI\n"
                    }
                    
                    if  self.sendLoginRequest()  == true {
                        println("Login Successful")
                    }
                    else {
                        println("Login Error: password/userID missing")
                        self.textField.text = self.textField.text + "Login Error: password/userID missing"
                    }
                }
            }
        })
        task.resume()
    }
    
    
    func extractURLfromBody(bodyData: NSString) -> NSString? {
        if debugMode {
            self.textField.text = self.textField.text + "\n\n100 <extractURLfromBody> called \n"
        }
        //check for redirection link
        if let redirURL = parse( bodyData,  open: "window.location.href='", close: "'\">") {
            return redirURL
        }
        else {//<IFRAME src="
            if let redirURL = parse( bodyData,  open: "<IFRAME src=\"", close: "\"") {
                return redirURL
            }
            return nil
        }
        
    }
    
    
    //Helper functions
    func parse(thing: NSString, open: NSString, close: NSString ) -> NSString?
    {
        var divRange:NSRange = thing.rangeOfString(open as String, options:NSStringCompareOptions.CaseInsensitiveSearch);
        if (divRange.location != NSNotFound)
        {
            var endDivRange = NSMakeRange(divRange.length + divRange.location, thing.length - ( divRange.length + divRange.location))
            endDivRange = thing.rangeOfString(close as String, options:NSStringCompareOptions.CaseInsensitiveSearch, range:endDivRange);
            
            if (endDivRange.location != NSNotFound)
            {
                divRange.location += divRange.length;
                divRange.length  = endDivRange.location - divRange.location;
            }
            return thing.substringWithRange(divRange);
        }
        return nil;
    }
    
    
    func startTimer() {
        if let timerInterval:NSString = NSUserDefaults.standardUserDefaults().stringForKey(kTimer)  {
            stopTimer()
            println("Starting Timer with: \(timerInterval)")
            logonTimer = NSTimer.scheduledTimerWithTimeInterval(timerInterval.doubleValue, target: self, selector: "doLogon", userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        if let timer = logonTimer {
            timer.invalidate()
            logonTimer = nil
            println("Timer stopped")
        }
    }
}

