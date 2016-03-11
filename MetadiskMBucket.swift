//
//  Bucket.swift
//  Metadisk
//
//  Created by Jan Potuznik on 10.03.16.
//  Copyright © 2016 donAFRO. All rights reserved.
//

import Foundation

public class Bucket {
    
    let id: String
    let name: String
//    let pubkeys: String
    let status: String
    let created: String
    let storage: Int
    let transfer: Int
    let user: String
    
    
    init(id: String, name: String, status: String, created: String, storage: Int, transfer: Int, user: String) {
        self.id = id
        self.name = name
//        self.pubkeys = pubkeys
        self.status = status
        self.created = created
        self.storage = storage
        self.transfer = transfer
        self.user = user
    }
}