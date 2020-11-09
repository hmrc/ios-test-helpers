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

class SharedData {

    static var bundle: Bundle!

    enum FileType: String {
        case json
        case html
        case atom
    }

    enum DirectoryType: String {
        case web = "WEB"
        case api = "API"
    }

    private static let testDataDir = "mobile-test-data/NGC"

    class func url(of filename: String,
                   inSharedTestDataDir subDir: String,
                   inDirectoryType directoryType: DirectoryType = .api,
                   withFileType fileType: FileType = .json) -> URL {

        let bundle = getBundle(for: filename, inSharedTestDataDir: subDir, withFileType: fileType)
        return url(from: bundle, filename: filename, inSharedTestDataDir: subDir, inDirectoryType: directoryType, withFileType: fileType)
    }

    class func from(filename: String,
                    inSharedTestDataDir subDir: String,
                    inDirectoryType directoryType: DirectoryType = .api,
                    withFileType fileType: FileType = .json,
                    substitutions: [String: String] = [:]) -> String {

        let bundle = getBundle(for: filename, inSharedTestDataDir: subDir, withFileType: fileType)

        var responseStr = string(from: bundle,
                                 filename: filename,
                                 inSharedTestDataDir: subDir,
                                 inDirectoryType: directoryType,
                                 withFileType: fileType)
        substitutions.forEach { (key, value) in
            responseStr = responseStr.replacingOccurrences(of: key, with: value)
        }
        return responseStr
    }

    private class func getBundle(for filename: String,
                                 inSharedTestDataDir subDir: String,
                                 inDirectoryType directoryType: DirectoryType = .api,
                                 withFileType fileType: FileType = .json) -> Bundle {
        if let bundle = bundle { return bundle }

        bundle = Bundle.allBundles.first { (bundle) -> Bool in
            let exists = fileExists(in: bundle,
                                    filename: filename,
                                    inSharedTestDataDir: subDir,
                                    inDirectoryType: directoryType,
                                    withFileType: fileType)
            return exists
        } ?? nil

        if bundle == nil {
            XCTFail("Could not locate bundle containing \(filename) of type \(fileType.rawValue) in \(subDir)")
        }

        return bundle
    }

    private class func fileExists(in bundle: Bundle,
                                  filename: String,
                                  inSharedTestDataDir subDir: String,
                                  inDirectoryType directoryType: DirectoryType,
                                  withFileType fileType: FileType) -> Bool {
        let fullDir = "\(testDataDir)/\(directoryType.rawValue)/\(subDir)"
        let path = bundle.path(forResource: filename, ofType: fileType.rawValue, inDirectory: fullDir) ?? "Whoops"

        return FileManager.default.fileExists(atPath: path)
    }

    private class func url(from bundle: Bundle,
                           filename: String,
                           inSharedTestDataDir subDir: String,
                           inDirectoryType directoryType: DirectoryType,
                           withFileType fileType: FileType) -> URL {
        let fullDir = "\(testDataDir)/\(directoryType.rawValue)/\(subDir)"
        guard let path = bundle.path(forResource: filename, ofType: fileType.rawValue, inDirectory: fullDir) else {
            XCTFail("Unable to load \(bundle.bundlePath)/\(fullDir)/\(filename).\(fileType)")
            return URL(fileURLWithPath: "Whoops")
        }
        return URL(fileURLWithPath: path)
    }

    private class func string(from bundle: Bundle,
                              filename: String,
                              inSharedTestDataDir subDir: String,
                              inDirectoryType directoryType: DirectoryType,
                              withFileType fileType: FileType) -> String {
        let fullDir = "\(testDataDir)/\(directoryType.rawValue)/\(subDir)"
        guard let path = bundle.path(forResource: filename, ofType: fileType.rawValue, inDirectory: fullDir) else {
            XCTFail("Unable to load \(bundle.bundlePath)/\(fullDir)/\(filename).\(fileType)")
            return "Whoops"
        }
        let url = URL(fileURLWithPath: path)

        //swiftlint:disable:next force_try
        return try! String(contentsOf: url, encoding: .utf8)
    }
}
