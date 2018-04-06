//
//  RunningAppsViewModelTests.swift
//  RunningAppsTests
//
//  Created by 横田孝次郎 on 2018/04/06.
//  Copyright © 2018年 横田孝次郎. All rights reserved.
//

import XCTest
@testable import RunningApps

class RunningAppsViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testInitializeFromValidBundleIdentifier() {
        let viewModel = RunningAppsViewModel(bundleIdentifiers: ["com.apple.dt.xcode"])
        XCTAssertNotNil(viewModel)
        XCTAssertTrue(viewModel.metaDatas.count > 0)
        let item = viewModel.metaDatas.first
        XCTAssertEqual(item!.name, "Xcode")
        XCTAssertEqual(item!.identifier, "com.apple.dt.Xcode")
        XCTAssertNotNil(item!.version)
        XCTAssertNotNil(item!.versionDesctiption)
        XCTAssertNotNil(item!.icon)
        XCTAssertEqual(item!.url, URL(fileURLWithPath: "/Applications/Xcode.app"))
        XCTAssertEqual(item!.isActive, true)
    }
    
    func testInitializeFromInValidBundleIdentifier() {
        let viewModel = RunningAppsViewModel(bundleIdentifiers: ["com.hoge.fuga"])
        XCTAssertNotNil(viewModel)
        XCTAssertTrue(viewModel.metaDatas.count == 0)
    }
}
