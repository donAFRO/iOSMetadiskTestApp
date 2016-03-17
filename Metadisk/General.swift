//
//  General.swift
//  Metadisk
//
//  Created by Jan Potuznik on 11.03.16.
//  Copyright © 2016 donAFRO. All rights reserved.
//

import Foundation


public class General {

    static var user = "mazeltov3@sharklasers.com"
    static var password = "a0de9a6204d75feec798619bb2c299584ebfe4846d40c65ff80bbd6ceb8016d9"
    
    static let credentialData = "\(user):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
    static let base64Credentials = credentialData.base64EncodedStringWithOptions([])
    static let headers = ["Authorization": "Basic \(base64Credentials)"]
}