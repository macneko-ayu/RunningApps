//
//  AppListItemModelTests.swift
//  RunningAppsTests
//
//  Created by 横田孝次郎 on 2017/01/24.
//  Copyright © 2017年 macneko. All rights reserved.
//

import XCTest
@testable import RunningApps

class AppListItemModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitislizeAppListItem() {
        let model = AppListItemModel.AppListItem(name: "Xcode", url: URL(fileURLWithPath: "/Applications/Xcode.app"), identifier: "com.apple.dt.xcode", version: "1", versionDesctiption: "verson 1", icon: nil, isActive: false)
        XCTAssertNotNil(model)
    }

    func testInitializeFromValidBundleIdentifier() {
        let model = AppListItemModel(bundleIdentifiers: ["com.apple.dt.xcode"])
        XCTAssertNotNil(model)
        XCTAssertTrue(model.items.count > 0)
        let item = model.items.first
        XCTAssertEqual(item!.name, "Xcode")
        XCTAssertEqual(item!.identifier, "com.apple.dt.Xcode")
        XCTAssertNotNil(item!.version)
        XCTAssertNotNil(item!.versionDesctiption)
        XCTAssertNotNil(item!.icon)
        XCTAssertEqual(item!.url, URL(fileURLWithPath: "/Applications/Xcode.app"))
        XCTAssertEqual(item!.isActive, true)
    }
    
    func testInitializeFromInValidBundleIdentifier() {
        let model = AppListItemModel(bundleIdentifiers: ["com.hoge.fuga"])
        XCTAssertNotNil(model)
        XCTAssertTrue(model.items.count == 0)
    }

}
