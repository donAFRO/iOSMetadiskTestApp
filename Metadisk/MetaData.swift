//
//  MetaData.swift
//  Metadisk
//
//  Created by Jan Potuznik on 13.03.16.
//  Copyright © 2016 donAFRO. All rights reserved.
//

import Foundation


public class MetaData {
    let fileName: String
    let hash: String
    let id: String
    let mimetype: String
    let size: Int64
    
    init(fileName: String, hash: String, id: String, mimetype: String, size: Int64) {
        self.fileName = fileName
        self.hash = hash
        self.id = id
        self.mimetype = mimetype
        self.size = size
    }
}