/*
 * Copyright 2022 HM Revenue & Customs
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

import XCTest

///XCTAttachments for core (and UI) unit tests
enum Attachment {
    case testLog
    case appErrorScreenshot(name: String)

    static var logDirectory: URL? {
        guard let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        return URL(fileURLWithPath: docsDir)
    }

    var logFile: URL? {
        guard let logDir = Attachment.logDirectory else { return nil }
        switch self {
        case .testLog:
            return logDir.appendingPathComponent("test.log", isDirectory: false)
        case .appErrorScreenshot:
            return nil
        }
    }

    var attachment: XCTAttachment? {
        switch self {
        case .testLog:
            guard let logFile = logFile else { return nil }
            return XCTAttachment(contentsOfFile: logFile, uniformTypeIdentifier: "txt")

        case .appErrorScreenshot(let name):
            return takeScreenshot(name)
        }
    }

    private func takeScreenshot(_ name: String) -> XCTAttachment {
        let name = name.lowercased().contains(find: "png") ? name : name + ".png"
        let screenshot = XCUIScreen.main.screenshot()
        let image = screenshot.image
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        return attachment
    }
}
