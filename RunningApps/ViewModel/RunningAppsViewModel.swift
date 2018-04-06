//
//  RunningAppsViewModel.swift
//  RunningApps
//
//  Created by 横田孝次郎 on 2018/04/06.
//  Copyright © 2018年 横田孝次郎. All rights reserved.
//

import Cocoa

protocol UpdatedRunningAppsStateDelegate {
    func refresh()
}

class RunningAppsViewModel: NSObject {
    @objc dynamic var metaDatas = [ApplicationMetaData]()
    var delegate: UpdatedRunningAppsStateDelegate?
    
    override init() {
        super.init()
        self.setupObserver()
    }
    
    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    // MARK: Public Methods

    /// 保持しているMetaDataを更新
    ///
    /// - Parameter bundleIdentifiers: 更新対象のBundleIndetifier
    public func updateMetaDatas(bundleIdentifiers: [String]) {
        bundleIdentifiers.forEach { (identifier: String) in
            let metaDatas = makeMetaDatas(bundleIndentifier: identifier)
            let filteredMetaDatas = metaDatas.filter { $0.isActive && $0.identifier != Bundle.main.bundleIdentifier }
            let sortedMetaDatas = filteredMetaDatas.sorted(by: { $0.name < $1.name })
            sortedMetaDatas.forEach { self.metaDatas.append($0) }
        }
    }
    
    // MARK: Private Methods

    /// MetaDataを作成
    ///
    /// - Parameter bundleIndentifier: 作成対象のBundleIndetifier
    /// - Returns: 作成したMetaDataの配列
    private func makeMetaDatas(bundleIndentifier: String) -> [ApplicationMetaData] {
        // BundleIdentifierにマッチするApplicationのファイルUrlを取得
        // 同じBundleIdentifierのApplicationがインストールされている場合もあり得るので配列となる
        guard let appUrls = LSCopyApplicationURLsForBundleIdentifier(bundleIndentifier as CFString, nil)?.takeUnretainedValue() as? [URL] else {
            return []
        }
        let appMetaDatas = appUrls.compactMap { (appUrl: URL) -> ApplicationMetaData? in
            guard let bundle = Bundle(url: appUrl), let identifier = bundle.bundleIdentifier, let infoDictionary = bundle.infoDictionary else {
                return nil
            }
            // 重複を防ぐため、登録済かチェックする
            if let _ = self.metaDatas.index(where: { $0.identifier == identifier && $0.url.path == appUrl.path }) {
                return nil
            }

            let path = appUrl.path
            let name = FileManager.default.displayName(atPath: path).components(separatedBy: ".").first ?? ""
            let icon = NSWorkspace.shared.icon(forFile: path)
            let version = infoDictionary["CFBundleVersion"] as? String ?? "unknown"
            let versionDesctiption = "version \(version)"
            
            let runningApps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == NSApplication.ActivationPolicy.regular }
            let activeState = runningApps.compactMap { $0.bundleURL }.filter { $0.path == appUrl.path }.count > 0
            return ApplicationMetaData(name: name, url: appUrl, identifier: identifier, version: version, versionDesctiption: versionDesctiption, icon: icon, isActive: activeState)
        }
        return appMetaDatas
    }
    
    /// Observerを設定
    private func setupObserver() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidLaunch(notification:)), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidTerminate(notification:)), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
    }
    
    // MARK: Notification Methods
    
    /// アプリ起動時にリストを更新（自身は含めない）
    ///
    /// - Parameter notification: Notification
    @objc private func appDidLaunch(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let identifier = app.bundleIdentifier else { return }
        if identifier == Bundle.main.bundleIdentifier {
            return
        }
        updateMetaDatas(bundleIdentifiers: [identifier])
        delegate?.refresh()
    }
    
    /// アプリ終了時にリストを更新
    ///
    /// - Parameter notification: Notification
    @objc private func appDidTerminate(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let identifier = app.bundleIdentifier,
            let appUrl = app.bundleURL,
            let index = metaDatas.index(where: { $0.identifier == identifier && $0.url.path == appUrl.path }) else { return }
        metaDatas.remove(at: index)
        delegate?.refresh()
    }

    
    
    

}
