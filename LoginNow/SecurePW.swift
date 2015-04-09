//
//  SecurePW.swift
//  LoginNow
//
//  Created by Martin Brunner on 13.02.15.
//  Copyright (c) 2015 Martin Brunner. All rights reserved.
//

import UIKit
import Security

func encryptPW ( pw: String) -> String {
    
    let parameters:NSDictionary = NSDictionary(objects: [kSecAttrKeyTypeRSA, 1024], forKeys: [kSecAttrKeyType,kSecAttrKeySizeInBits])
    
    var publicKeyPtr, privateKeyPtr: Unmanaged<SecKey>?
    var result = SecKeyGeneratePair(parameters, &publicKeyPtr, &privateKeyPtr)
    
    let publicKey: SecKeyRef = publicKeyPtr!.takeRetainedValue()
    let privateKey = privateKeyPtr!.takeRetainedValue()
    
    
    
    
    let blockSize:UInt8 = UInt8(SecKeyGetBlockSize(publicKey))
    
    let plainTextData = [UInt8](pw.utf8)
    
    
//    let plainTextDataLength = pw.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    let plainTextDataLength = Int(pw.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    
    var encryptedData = [UInt8](count: Int(blockSize), repeatedValue: 0)
    var encryptedDataLength:Int = Int(blockSize)
    
//    result = SecKeyEncrypt(publicKey, UInt32( SecPadding(kSecPaddingPKCS1)), plainTextData, plainTextDataLength, encryptedData, &encryptedDataLength)

    result = SecKeyEncrypt(publicKey, SecPadding(kSecPaddingPKCS1), plainTextData, plainTextDataLength, &encryptedData, &encryptedDataLength)
    
    var decryptedData = [UInt8](count: Int(blockSize), repeatedValue: 0)
    var decryptedDataLength:Int = Int( blockSize)
    
    let data = NSData(bytes: encryptedData, length: encryptedData.count)
    //    KeychainService.saveToken(data, service: servicePassword)
    
    
    var newData = [UInt8](count: encryptedData.count, repeatedValue: 0) // as UnsafeMutablePointer<UInt8>
    //    let dataFromKeyChain:NSData = KeychainService.loadToken(servicePassword)!
    
    //    dataFromKeyChain.getBytes(&newData, length:dataFromKeyChain.length)
    
    result = SecKeyDecrypt(privateKey, SecPadding(kSecPaddingPKCS1), newData, encryptedDataLength, &decryptedData, &decryptedDataLength)
    
    let decryptedText = String(bytes: decryptedData, encoding:NSUTF8StringEncoding)
    
    return decryptedText!
}

func decryptPW() -> String {
    
    return ""
}