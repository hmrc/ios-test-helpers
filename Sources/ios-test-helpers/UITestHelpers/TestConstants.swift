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

public extension Test {

    struct Data { }
    struct Dates {
        static let middayOn12thApril2017 = Date(timeIntervalSince1970: 1491998400)
        static let OneOClockPMOn12thApril2017 = Date(timeIntervalSince1970: 1492002000)
        static let middayOn1stNovember2017 = Date(timeIntervalSince1970: 1509537600)
        static let middayOn1stNovember2019 = Date(timeIntervalSince1970: 1572609600)
        static let middayOn5thMarch1969 = Date(timeIntervalSince1970: -26049600)
        static let utcMidnightAtStartOf16thApril2018 = Date(timeIntervalSince1970: 1523836800)

        //swiftlint:disable identifier_name
        static let _2018_01 = Date(timeIntervalSince1970: 1514764800)
        static let _2018_01_16 = Date(timeIntervalSince1970: 1516060800)
        static let _2018_01_31 = Date(timeIntervalSince1970: 1517356800)
        static let _2018_02_18 = Date(timeIntervalSince1970: 1518912000)
        static let _2018_02_20 = Date(timeIntervalSince1970: 1519084800)
        static let _2018_02_22 = Date(timeIntervalSince1970: 1519257600)
        static let _2018_02_25 = Date(timeIntervalSince1970: 1519516800)
        static let _2018_02_28 = Date(timeIntervalSince1970: 1519776000)
        static let _2018_03_01 = Date(timeIntervalSince1970: 1519862400)
        static let _2018_04_15 = Date(timeIntervalSince1970: 1523833200)
        static let _2018_05_18 = Date(timeIntervalSince1970: 1526598000)
        static let _2018_05_23 = Date(timeIntervalSince1970: 1527030000)
        static let _2019_04_06 = Date(timeIntervalSince1970: 1554505200)
        static let _2019_12_31 = Date(timeIntervalSince1970: 1577750400)
        static let _2020_01_01 = Date(timeIntervalSince1970: 1577836800)
        static let _2020_01_12_09_59_59 = Date(timeIntervalSince1970: 1578823199)
        static let _2020_01_12_10_00_00 = Date(timeIntervalSince1970: 1578823200)
        static let _2020_01_12_10_00_01 = Date(timeIntervalSince1970: 1578823201)
        static let _2020_01_16 = Date(timeIntervalSince1970: 1579132800)
        static let _2020_01_31 = Date(timeIntervalSince1970: 1580428800)
        static let _2020_02_01 = Date(timeIntervalSince1970: 1580515200)
        static let _2020_02_28 = Date(timeIntervalSince1970: 1582848000)
        static let _2020_04_10 = Date(timeIntervalSince1970: 1586476800)
        static let _2020_04_06 = Date(timeIntervalSince1970: 1586127600)
        static let _2022_01_31 = Date(timeIntervalSince1970: 1643587200)
        static let _2022_02_01 = Date(timeIntervalSince1970: 1643673600)
        //swiftlint:enable identifier_name
    }
}
