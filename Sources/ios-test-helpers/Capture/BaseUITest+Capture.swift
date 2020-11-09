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

extension BaseUITest {

    func capture(screen: Capture.Screen) {
        sleep(2)
        guard let srcroot = ProcessInfo.processInfo.environment["SRCROOT"] else { return }

        guard let filepath = performScreenCapture(screen: screen) else { return }

        let fileManager = FileManager.default
        var fileExists = false
        var retryCount = 5
        while !fileExists && retryCount > 0 {
            fileExists = fileManager.fileExists(atPath: filepath)
            retryCount -= 1
            sleep(1)
        }
        guard fileExists else { return }

        guard
            let srcrootFolder = try? Folder(path: "\(srcroot)"),
            let artifactsFolder = try? srcrootFolder.createSubfolderIfNeeded(withName: "Artifacts"),
            let captureFolder = try? artifactsFolder.createSubfolderIfNeeded(withName: "capture"),
            let screensFolder = try? captureFolder.createSubfolderIfNeeded(withName: "screens"),
            let sourceFile = try? File(path: filepath) else {
            return
        }

        if let file = try? screensFolder.file(named: URL(fileURLWithPath: filepath).lastPathComponent) {
            do {
                try file.delete()
            } catch {
                return
            }
        }

        do {
            try sourceFile.move(to: screensFolder)
        } catch {
            return
        }
    }

    func performScreenCapture(screen: Capture.Screen) -> String? {
        let filepath: String? = {
            let result = self.app.performCustomCommandNamed("captureScreen", object: screen.rawValue)
            return result as? String
        }()
        return filepath
    }
}

#endif
