//
//  General.swift
//  Metadisk
//
//  Created by Jan Potuznik on 11.03.16.
//  Copyright © 2016 donAFRO. All rights reserved.
//

import Foundation


public class General {

    static let user = "mazeltov3@sharklasers.com"
    static let password = "mazeltov3@sharklasers.com"
    
    static let credentialData = "\(user):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
    static let base64Credentials = credentialData.base64EncodedStringWithOptions([])
    static let headers = ["Authorization": "Basic \(base64Credentials)"]
}