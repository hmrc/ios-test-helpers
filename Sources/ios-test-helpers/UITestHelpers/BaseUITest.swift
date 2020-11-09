/*
 * Copyright 2019 HM Revenue & Customs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#if ENABLE_UITUNNEL

import Foundation
import SBTUITestTunnelClient
import XCTest

class BaseUITest: CoreTestCase {

    static var deviceAndAppInfo: String?

    var requireForceUpgrade: Bool = false

    public override func setUp() {
        super.setUp()
        assertAccessibilityIsOff()
        continueAfterFailure = false

        #if SCREENSHOT
        setupSnapshot(app)
        #endif

        launchApp()

        addUIInterruptionMonitor(withDescription: "Accept Notifications") { (alert) -> Bool in
            let okButton = alert.buttons["OK"]
            if okButton.waitForExistence(timeout: 10) {
                okButton.tap()
            }
            return true
        }
    }

    func launchApp() {
//        app.launchArguments.append("ui-testing")
//        app.launchArguments.append(contentsOf: ["-AppleLanguages", "(en-GB)", "-AppleLocale", "en-GB"])
//        if shouldShowDebugOverlay() {
//            app.launchArguments.append("ui-testing-show-debug-overlay")
//        }
//        appendLaunchArguments()
//        app.launchTunnel(withOptions: [
//            SBTUITunneledApplicationLaunchOptionDisableUITextFieldAutocomplete]) {
//                Stub.setTestCase(testCase: self)
//                Stub.Login.stub_fullLoginFlow(requireForceUpgrade: self.requireForceUpgrade)
//                Stub.Audit.stub_Audit()
//                #if SCREENSHOT
//                // Do not fix the date
//                #else
//                _ = self.app.performCustomCommandNamed(
//                    "setFixedDate",
//                    object: Test.Dates.middayOn1stNovember2019
//                )
//                #endif
//
//                if BaseUITest.deviceAndAppInfo == nil {
//                    BaseUITest.deviceAndAppInfo = self.app.performCustomCommandNamed(
//                        "getDeviceAndAppInfo",
//                        object: nil
//                        ) as? String
//                }
//        }
    }

    private func shouldShowDebugOverlay() -> Bool {
        ProcessInfo.processInfo.arguments.contains("-HMRC.Components.ShowOverlay")
    }

    public override func tearDown() {
        enableWaitForIdle()
        app.stubRequestsRemoveAll()
        app.userDefaultsReset()
        app.performCustomCommandNamed("resetFixedDate", object: nil)
        super.tearDown()
    }

    func appendLaunchArguments() {
        // Override in sub-class
    }

    func assertLabelExists(identifier: String) {
        XCTAssertTrue(app.staticTexts.matching(identifier: identifier).element(boundBy: 0).exists)
    }

    func tapButtonWithId(_ id: String, file: StaticString = #file, line: UInt = #line) {
        let buttonsQuery = self.app.buttons.matching(identifier: id)
        let button = buttonsQuery.element(boundBy: 0)
        XCTAssertTrue(button.exists, "Button with ID: \(id) doesn't exist", file: file, line: line)
        button.tap()
    }

    func tapButtonWithLabel(_ label: String) {
        let button = self.app.buttons[label]
        XCTAssert(button.exists)
        button.tap()
    }

    func forceClearDeclarationsCache() {
        _ = self.app.performCustomCommandNamed("forceClearDeclarationsCache", object: nil)
        sleep(1)
    }

    func forceSetFixedDate2017() {
        _ = self.app.performCustomCommandNamed("setFixedDate", object: nil)
        sleep(1)
    }

    func forceJavascriptError() {
        _ = self.app.performCustomCommandNamed("forceJavascriptError", object: nil)
    }

    func getLastOpenedURL() -> String? {
        (self.app.performCustomCommandNamed("getLastOpenedURL", object: nil) as? String)
    }

    func getRateCalled() -> Bool {
        (self.app.performCustomCommandNamed("getRateCalled", object: nil) as? Bool) ?? false
    }

    func getRecordedAnalyticsServiceEvents() -> [RecordedAnalyticsEvent] {
        guard let events =
            self.app.performCustomCommandNamed("getRecordedAnalyticsServiceEvents", object: nil) as? NSArray else {
                return []
        }

        let recordedEvents: [RecordedAnalyticsEvent] = events.map { event in
            guard let eventDict = event as? [String: Any] else {
                return RecordedAnalyticsEvent(
                    viewName: nil,
                    eventCategory: nil,
                    eventAction: nil,
                    eventLabel: nil,
                    eventValue: nil,
                    htsAccountDimensionState: nil,
                    p800DimensionValue: nil
                )
            }

            return RecordedAnalyticsEvent(
                viewName: eventDict["viewName"] as? String,
                eventCategory: eventDict["eventCategory"] as? String,
                eventAction: eventDict["eventAction"] as? String,
                eventLabel: eventDict["eventLabel"] as? String,
                eventValue: eventDict["eventValue"] as? NSNumber,
                htsAccountDimensionState: eventDict["htsAccountDimensionState"] as? String,
                p800DimensionValue: eventDict["p800DimensionValue"] as? String
            )
        }

        return recordedEvents
    }

    typealias RecordedAnalyticsEvent = (
        viewName: String?,
        eventCategory: String?,
        eventAction: String?,
        eventLabel: String?,
        eventValue: NSNumber?,
        htsAccountDimensionState: String?,
        p800DimensionValue: String?
    )

    func getRecordedAuditServiceEvents() -> [RecordedAuditEvent] {
        guard let events =
            self.app.performCustomCommandNamed("getRecordedAuditServiceEvents", object: nil) as? NSArray else {
                return []
        }

        let recordedEvents: [RecordedAuditEvent] = events.map { event in
            guard let eventDict = event as? [String: Any] else {
                return RecordedAuditEvent(eventType: "", eventDetail: nil, eventPath: nil)
            }

            return RecordedAuditEvent(
                eventType: eventDict["eventType"] as? String ?? "",
                eventDetail: eventDict["eventDetail"] as? [String: String],
                eventPath: eventDict["eventPath"] as? String)
        }

        return recordedEvents
    }

    typealias RecordedAuditEvent = (
        eventType: String,
        eventDetail: [String: String]?,
        eventPath: String?
    )

    func getFirebaseUserProperties() -> RecordedFirebaseProperties {
        guard let properties = self.app.performCustomCommandNamed("getRecordedUserProperties", object: nil) as? NSDictionary else {
            return [:]
        }

        //swiftlint:disable:next line_length
        let recordedProperties: RecordedFirebaseProperties = properties.reduce(RecordedFirebaseProperties()) { (result, next) -> RecordedFirebaseProperties in
            guard let key = next.key as? String, let value = next.value as? String else { return result }
            var variableResult = result
            variableResult[key] = value
            return variableResult
        }
        return recordedProperties
    }

    func getRecordedFirebaseEvents() -> [RecordedFirebaseEvent] {
        guard let events =
            self.app.performCustomCommandNamed("getRecordedFirebaseEvents", object: nil) as? NSArray else {
                return []
        }

        let recordedEvents: [RecordedFirebaseEvent] = events.map { event in
            guard let eventDict = event as? [String: Any?] else {
                return RecordedFirebaseEvent(event: "", parameters: nil)
            }

            return RecordedFirebaseEvent(
                event: eventDict["event"] as? String ?? "",
                parameters: eventDict["parameters"] as? [String: String]
            )
        }

        return recordedEvents
    }

    typealias RecordedFirebaseEvent = (
        event: String,
        parameters: [String: String]?
    )

    typealias RecordedFirebaseProperties = [String: String]

    // MARK: - Methods for swizzling out implicit waitForIdle checking in UI tests (use with care)

    static var haveSwizzledOutIdle = false

    func disableWaitForIdle() {
        if !Self.haveSwizzledOutIdle {
            guard let applicationProcess = objc_getClass("XCUIApplicationProcess") as? AnyClass,
                let original = class_getInstanceMethod(applicationProcess, Selector(("waitForQuiescenceIncludingAnimationsIdle:"))),
                let replaced = class_getInstanceMethod(type(of: self), #selector(Self.replaceIdleCheck)) else { return  }

            method_exchangeImplementations(original, replaced)
            Self.haveSwizzledOutIdle = true
        }
    }

    func enableWaitForIdle() {
        if Self.haveSwizzledOutIdle {
            guard let applicationProcess = objc_getClass("XCUIApplicationProcess") as? AnyClass,
                let original = class_getInstanceMethod(applicationProcess, Selector(("waitForQuiescenceIncludingAnimationsIdle:"))),
                let replaced = class_getInstanceMethod(type(of: self), #selector(Self.replaceIdleCheck)) else { return  }

            method_exchangeImplementations(replaced, original)
            Self.haveSwizzledOutIdle = false
        }
    }

    @objc func replaceIdleCheck() {
        }
}

#endif
