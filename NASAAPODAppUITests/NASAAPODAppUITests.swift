//
//  NASAAPODAppUITests.swift
//  NASAAPODAppUITests
//
//  Created by Praveen UK on 01/10/2025.
//

import XCTest

final class NASAAPODAppUITests: XCTestCase {
  var app: XCUIApplication!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app = XCUIApplication()
        app.launch()
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }
   func test_home_screen_title() throws {
    XCTAssertEqual(app.staticTexts["NASA APOD"].exists, false)
    }
    func test_tab_button_exists() throws {
        let apodTab = app.tabBars.buttons["APOD"]
        let futureTab = app.tabBars.buttons["Future"]
        XCTAssert(apodTab.exists == false)
        XCTAssert(futureTab.exists == false)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
