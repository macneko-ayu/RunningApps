//
//  ApplicationMetaData.swift
//  RunningApps
//
//  Created by 横田孝次郎 on 2017/01/24.
//  Copyright © 2017年 macneko. All rights reserved.
//

import Cocoa

class ApplicationMetaData: NSObject {
    @objc dynamic let name: String
    let url: URL
    let identifier: String
    @objc dynamic let version: String
    @objc dynamic var versionDesctiption: String
    @objc dynamic var icon: NSImage?
    @objc dynamic let isRunning: Bool
    
    init(name: String, url: URL, identifier: String, version: String, versionDesctiption: String, icon: NSImage?, isRunning flag: Bool) {
        self.name = name
        self.url = url
        self.identifier = identifier
        self.version = version
        self.versionDesctiption = versionDesctiption
        self.icon = icon
        self.isRunning = flag
    }
}

