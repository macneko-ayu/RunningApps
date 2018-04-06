//
//  RunningAppsViewController.swift
//  RunningApps
//
//  Created by 横田孝次郎 on 2017/01/24.
//  Copyright © 2017年 macneko. All rights reserved.
//

import Cocoa

class RunningAppsViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var appListArrayController: NSArrayController!
    @objc var items = [ApplicationMetaData]()

    // MARK: Initialization
    
    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    // MARK: LifeSycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        appListArrayController.sortDescriptors = [sortDescriptor]
        loadItems()
        setupObserver()
    }

    // MARK: Private Methods
    
    // 初回起動時に起動中のアプリケーション一覧を取得してArrayControllerに反映（自身は含めない）
    private func loadItems() {
        let runningApps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == NSApplication.ActivationPolicy.regular }
        let bundleIdentifiers = runningApps.flatMap { $0.bundleIdentifier }
        let listItems = RunningAppsViewModel(bundleIdentifiers: bundleIdentifiers).metaDatas.filter { $0.isActive && $0.identifier != Bundle.main.bundleIdentifier }
        listItems.forEach { appListArrayController.addObject($0) }
        DispatchQueue.main.async {
            self.appListArrayController.rearrangeObjects()
        }
    }
    
    // Observerを設定
    private func setupObserver() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidLaunch(notification:)), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidTerminate(notification:)), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
    }
    
    // MARK: Notification Methods
    
    // アプリ起動時にリストを更新（自身は含めない）
    @objc private func appDidLaunch(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let identifier = app.bundleIdentifier,
            let appUrl = app.bundleURL else { return }
        if identifier == Bundle.main.bundleIdentifier {
            return
        }
        let listItems = RunningAppsViewModel(bundleIdentifiers: [identifier]).metaDatas.filter { $0.url.path == appUrl.path }
        listItems.forEach { appListArrayController.addObject($0) }
        DispatchQueue.main.async {
            self.appListArrayController.rearrangeObjects()
        }
    }
    
    // アプリ終了時にリストを更新
    @objc private func appDidTerminate(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let identifier = app.bundleIdentifier,
            let appUrl = app.bundleURL,
            let arrangeObjects = appListArrayController.arrangedObjects as? [ApplicationMetaData],
            let index = arrangeObjects.index(where: { $0.identifier == identifier && $0.url.path == appUrl.path }) else { return }
        appListArrayController.remove(atArrangedObjectIndex: index)
        DispatchQueue.main.async {
            self.appListArrayController.rearrangeObjects()
        }
    }
}

extension RunningAppsViewController: NSTableViewDelegate {
    // TODO: UITableViewのように選択した感を出す方法を調査する
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        guard let arrangeObjects = appListArrayController.arrangedObjects as? [ApplicationMetaData] else { return false }
        let item = arrangeObjects[row]
        guard let app = NSWorkspace.shared.runningApplications
            .filter ({ (app: NSRunningApplication) in app.activationPolicy == NSApplication.ActivationPolicy.regular })
            .filter ({ (app: NSRunningApplication) in app.bundleIdentifier == item.identifier && app.bundleURL?.path == item.url.path }).first
            else { return false }
        app.activate(options: [])
        return false
    }
}
