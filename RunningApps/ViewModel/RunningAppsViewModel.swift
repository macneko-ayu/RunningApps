//
//  RunningAppsViewModel.swift
//  RunningApps
//
//  Created by 横田孝次郎 on 2018/04/06.
//  Copyright © 2018年 横田孝次郎. All rights reserved.
//

import Cocoa

class RunningAppsViewModel: NSObject {
    @objc dynamic let metaDatas: [ApplicationMetaData]
    
    init(bundleIdentifiers: [String] = [""]) {
        var result = [ApplicationMetaData]()
        bundleIdentifiers.forEach { (identifier: String) in
            // BundleIdentifierにマッチするApplicationのファイルUrlを取得
            // 同じBundleIdentifierのApplicationがインストールされている場合もあり得るので配列となる
            guard let appUrls = LSCopyApplicationURLsForBundleIdentifier(identifier as CFString, nil)?.takeUnretainedValue() as? [URL] else {
                return
            }
            let apps = appUrls.flatMap { (appUrl: URL) -> ApplicationMetaData? in
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
                return ApplicationMetaData(name: name, url: appUrl, identifier: identifier, version: version, versionDesctiption: versionDesctiption, icon: icon, isActive: activeState)
            }
            result.append(contentsOf: apps)
        }
        self.metaDatas = result.sorted(by: { $0.name < $1.name })
    }
}
