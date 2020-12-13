//
//  RunningAppsViewModel.swift
//  RunningApps
//
//  Created by Kojiro  Yokota on 2020/12/08.
//  Copyright © 2020 macneko.com. All rights reserved.
//

import Cocoa

final class RunningAppsViewModel: ObservableObject {
    @Published var metaData = [ApplicationMetaData]()
    let windowMinWidth: CGFloat = 250
    let rowMinHeight: CGFloat = 52

    init() {
        setupObserver()
        initializeMetaData()
    }
}

/// Public Methods
extension RunningAppsViewModel {
    /// 保持しているMetaDataを更新
    ///
    /// - Parameter bundleIdentifiers: 更新対象のBundleIdentifier
    public func updateMetaData(bundleIdentifiers: [String]) {
        bundleIdentifiers.forEach { (identifier: String) in
            let data = makeMetaData(bundleIdentifier: identifier)
            let filteredMetaData = data.filter { $0.isRunning && $0.identifier != Bundle.main.bundleIdentifier }
            let sortedMetaData = filteredMetaData.sorted(by: { $0.name < $1.name })
            sortedMetaData.forEach { metaData.append($0) }
        }
    }
}

/// Private Methods
extension RunningAppsViewModel {
    /// MetaDataを初期化する
    private func initializeMetaData() {
        let runningApps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == NSApplication.ActivationPolicy.regular }
        let bundleIdentifiers = runningApps.compactMap { $0.bundleIdentifier }
        updateMetaData(bundleIdentifiers: bundleIdentifiers)
    }

    /// MetaDataを作成
    ///
    /// - Parameter bundleIdentifier: 作成対象のBundleIdentifier
    /// - Returns: 作成したMetaDataの配列
    private func makeMetaData(bundleIdentifier: String) -> [ApplicationMetaData] {
        // BundleIdentifierにマッチするApplicationのファイルUrlを取得
        // 同じBundleIdentifierのApplicationがインストールされている場合もあり得るので配列となる
        guard let appUrls = LSCopyApplicationURLsForBundleIdentifier(bundleIdentifier as CFString, nil)?.takeUnretainedValue() as? [URL] else {
            return []
        }
        let appMetaData = appUrls.compactMap { [weak self] (appUrl: URL) -> ApplicationMetaData? in
            guard let bundle = Bundle(url: appUrl),
                  let identifier = bundle.bundleIdentifier,
                  let infoDictionary = bundle.infoDictionary else {
                return nil
            }
            // 重複を防ぐため、登録済かチェックする
            if let _ = self?.metaData.firstIndex(where: { $0.identifier == identifier && $0.url.path == appUrl.path }) {
                return nil
            }

            let path = appUrl.path
            let name = self?.extractName(path: path) ?? "unknown"
            let icon = NSWorkspace.shared.icon(forFile: path)
            let version = infoDictionary["CFBundleVersion"] as? String ?? "unknown"

            let runningApps = NSWorkspace.shared.runningApplications
                    .filter { $0.activationPolicy == NSApplication.ActivationPolicy.regular }
            let runningState = runningApps.compactMap { $0.bundleURL }
                    .filter { $0.path == appUrl.path }
                    .count > 0
            return ApplicationMetaData(name: name, url: appUrl, identifier: identifier, version: version,
                    icon: icon, isRunning: runningState)
        }
        return appMetaData
    }

    /// ファイルパスからファイル名を抽出
    ///
    /// - Parameter path: ファイルパス
    /// - Returns: ファイル名
    private func extractName(path: String) -> String {
        var components = FileManager.default.displayName(atPath: path).split(separator: ".")
        components.removeLast()
        return components.joined(separator: ".")
    }

    /// Observerを設定
    private func setupObserver() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidLaunch(notification:)), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidTerminate(notification:)), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
    }
}

/// Notification Methods
extension RunningAppsViewModel {
    /// アプリ起動時にリストを更新（自身は含めない）
    ///
    /// - Parameter notification: Notification
    // TODO: 更新が走るようにする
    @objc private func appDidLaunch(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let identifier = app.bundleIdentifier else { return }
        if identifier == Bundle.main.bundleIdentifier { return }
        updateMetaData(bundleIdentifiers: [identifier])
    }

    /// アプリ終了時にリストを更新
    ///
    /// - Parameter notification: Notification
    // TODO: 更新が走るようにする
    @objc private func appDidTerminate(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let identifier = app.bundleIdentifier,
              let appUrl = app.bundleURL,
              let index = metaData.firstIndex(where: { $0.identifier == identifier && $0.url.path == appUrl.path }) else { return }
        metaData.remove(at: index)
    }
}

