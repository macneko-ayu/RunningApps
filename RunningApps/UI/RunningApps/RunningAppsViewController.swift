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
    @IBOutlet var runningAppsArrayController: NSArrayController!
    @objc let viewModel = RunningAppsViewModel()

    // MARK: Initialization
    
    deinit {
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
        runningAppsArrayController.sortDescriptors = [sortDescriptor]
        tableView.selectionHighlightStyle = .regular
        loadItems()
    }

    // MARK: Private Methods
    
    /// 起動時に起動中のアプリケーション一覧を取得してArrayControllerに反映（自身は含めない）
    private func loadItems() {
        let runningApps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == NSApplication.ActivationPolicy.regular }
        let bundleIdentifiers = runningApps.compactMap { $0.bundleIdentifier }
        viewModel.updateMetaDatas(bundleIdentifiers: bundleIdentifiers)
    }
}

extension RunningAppsViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let arrangeObjects = runningAppsArrayController.arrangedObjects as? [ApplicationMetaData] else { return }
        let index = tableView.selectedRow
        let rowView = tableView.rowView(atRow: index, makeIfNecessary: false)
        rowView?.isEmphasized = true
        let item = arrangeObjects[index]
        guard let app = NSWorkspace.shared.runningApplications
            .filter ({ (app: NSRunningApplication) in app.activationPolicy == NSApplication.ActivationPolicy.regular })
            .filter ({ (app: NSRunningApplication) in app.bundleIdentifier == item.identifier && app.bundleURL?.path == item.url.path }).first
            else { return }
        app.activate(options: [])
        tableView.deselectRow(index)
    }
}

extension RunningAppsViewController: UpdatedRunningAppsStateDelegate {
    
    /// リストを更新
    func refresh() {
        DispatchQueue.main.async {
            self.runningAppsArrayController.rearrangeObjects()
        }
    }
}
