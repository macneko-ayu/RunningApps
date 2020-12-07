//
//  ApplicationMetaData.swift
//  RunningApps
//
//  Created by Kojiro Yokota on 2020/12/7.
//  Copyright © 2020年 macneko.com. All rights reserved.
//

import Cocoa

struct ApplicationMetaData: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    let identifier: String
    let version: String
    var versionDescription: String {
        return "version: \(version)"
    }
    let icon: NSImage?
    let isRunning: Bool
    
    init(name: String, url: URL, identifier: String, version: String, icon: NSImage?, isRunning: Bool) {
        self.name = name
        self.url = url
        self.identifier = identifier
        self.version = version
        self.icon = icon
        self.isRunning = isRunning
    }
}

