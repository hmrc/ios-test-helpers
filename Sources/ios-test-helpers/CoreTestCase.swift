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

import Foundation
import XCTest

open class CoreTestCase: XCTestCase {
    public typealias FailureReasonHandler = (() -> String)

    ///Global control of logs produced by calling info(_) on subclasses of this type
    ///This is overriden by set(logging:)
    static let loggingEnabledByDefault = true

    // MARK: - Helpers
    private(set) var loggingEnabled = loggingEnabledByDefault

    public func set(logging enabled: Bool) -> Self {
        loggingEnabled = enabled
        return self
    }

    public func info(_ message: String) {
        guard loggingEnabled else { return }

        let clsName = String(describing: self.classForCoder)
        print("\(clsName) - \(message)")
    }

    // MARK: - Assertion helpers

    public func assertAccessibilityIsOff() {
        let fontScale = UIFont.preferredFont(forTextStyle: .body).pointSize / 17.0
        assert(
            fontScale == 1,
            "Large text (accessibility) is enabled. Please disable it in the simulator."
        )
    }

    public func assertString(_ string: String?,
                             contains subString: String,
                             in file: String = #file,
                             at line: Int = #line) {
        assertTrue(
            string?.contains(subString) ?? false,
            in: file,
            at: line) { return "Expected \"\(subString)\" to be contained in \"\(string ?? "")\""}
    }

    public func assertTrue(_ value: Bool, in file: String = #file, at line: Int = #line, _ failReason: FailureReasonHandler) {
        if !value {
            recordFailure(
                withDescription: failReason(),
                inFile: file,
                atLine: line,
                expected: true)
        }
    }

    public func assertFalse(_ value: Bool, in file: String = #file, at line: Int = #line, _ failReason: FailureReasonHandler) {
        assertTrue(!value, in: file, at: line, failReason)
    }

    public func assertNotNil(_ value: Any?, in file: String = #file, at line: Int = #line, _ failReason: FailureReasonHandler) {
        if value == nil {
            recordFailure(
                withDescription: failReason(),
                inFile: file,
                atLine: line,
                expected: true)
        }
    }

    public func failTest(_ reason: String, in file: String = #file, at line: Int = #line) {
        assertTrue(false, in: file, at: line) {
            return reason
        }
    }

    ///Waits until the code in retry block returns nil. If the operation times out then the last fail reason returned by the retry handler
    ///is returned
    public func waitUntil(
        _ description: String,
        timeout: TimeInterval=Test.Timeout,
        in file: String = #file,
        at line: Int = #line,
        _ retryBlock: Test.AssertionBlock
    ) -> String? {

        let finishTime = Date().addingTimeInterval(timeout)
        var timedOut = false
        var counter = 0
        var failReason: String?

        while !timedOut {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
            failReason = retryBlock()
            if failReason == nil {
                break
            }

            timedOut = Date() >= finishTime
            counter += 1
            if counter == 9 {
                print("- Fail reason: \(failReason!)")
                print("Waiting until '\(description)'")
                counter = 0
            }
        }

        if timedOut {
            return "Timed out waiting until: '\(description)' - reason: '\(failReason!)'"
        } else {
            return nil
        }
    }

    public func waitUntilOrAssert(
        _ description: String,
        timeout: TimeInterval = Test.Timeout,
        in file: String = #file,
        at line: Int = #line,
        _ assertionBlock: Test.AssertionBlock
    ) {

        if let failReason = waitUntil(description, timeout: timeout, in: file, at: line, assertionBlock) {
            failTest(failReason)
        }
    }
}
