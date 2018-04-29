//
//  ApplicationMetaDataTests.swift
//  RunningAppsTests
//
//  Created by 横田孝次郎 on 2017/01/24.
//  Copyright © 2017年 macneko. All rights reserved.
//

import XCTest
@testable import RunningApps

class ApplicationMetaDataTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitislizeApplicationMetaData() {
        let model = ApplicationMetaData(name: "Xcode", url: URL(fileURLWithPath: "/Applications/Xcode.app"), identifier: "com.apple.dt.xcode", version: "1", versionDesctiption: "verson 1", icon: nil, isRunning: false)
        XCTAssertNotNil(model)
    }
}
