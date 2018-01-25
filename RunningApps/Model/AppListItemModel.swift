//
//  AppListItemModel.swift
//  RunningApps
//
//  Created by 横田孝次郎 on 2017/01/24.
//  Copyright © 2017年 macneko. All rights reserved.
//

import Cocoa

class AppListItemModel: NSObject {
    @objc dynamic let items: [AppListItem]
    
    init(bundleIdentifiers: [String] = [""]) {
        var result = [AppListItem]()
        bundleIdentifiers.forEach { (identifier: String) in
            // BundleIdentifierにマッチするApplicationのファイルUrlを取得
            // 同じBundleIdentifierのApplicationがインストールされている場合もあり得るので配列となる
            guard let appUrls = LSCopyApplicationURLsForBundleIdentifier(identifier as CFString, nil)?.takeUnretainedValue() as? [URL] else {
                return
            }
            let apps = appUrls.flatMap { (appUrl: URL) -> AppListItem? in
                guard let bundle = Bundle(url: appUrl), let identifier = bundle.bundleIdentifier, let infoDictionary = bundle.infoDictionary else {
                    return nil
                }
                let path = appUrl.path
                let name = FileManager.default.displayName(atPath: path).components(separatedBy: ".").first ?? ""
                let icon = NSWorkspace.shared.icon(forFile: path)
                let version = infoDictionary["CFBundleVersion"] as? String ?? "unknown"
                let versionDesctiption = "version \(version)"

                let runningApps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == NSApplication.ActivationPolicy.regular }
                let activeState = runningApps.flatMap { $0.bundleURL }.filter { $0.path == appUrl.path }.count > 0
                return AppListItem(name: name, url: appUrl, identifier: identifier, version: version, versionDesctiption: versionDesctiption, icon: icon, isActive: activeState)
            }
            result.append(contentsOf: apps)
        }
        self.items = result.sorted(by: { $0.name < $1.name })
    }

    class AppListItem: NSObject {
        @objc dynamic let name: String
        let url: URL
        let identifier: String
        @objc dynamic let version: String
        @objc dynamic var versionDesctiption: String
        @objc dynamic var icon: NSImage?
        @objc dynamic let isActive: Bool
        
        init(name: String, url: URL, identifier: String, version: String, versionDesctiption: String, icon: NSImage?, isActive flag: Bool) {
            self.name = name
            self.url = url
            self.identifier = identifier
            self.version = version
            self.versionDesctiption = versionDesctiption
            self.icon = icon
            self.isActive = flag
        }
    }
}


