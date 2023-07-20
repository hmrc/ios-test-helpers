/*
 * Copyright 2021 HM Revenue & Customs
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

import ios_core_library
import XCTest

// swiftlint:disable identifier_name
open class MockDateService: CoreMockBase, DateService {

    private let instance = MobileCore.Date.Service()

    var stubbedShouldCurrentSceneDisplayWelshDates = false
    var invokedShouldCurrentSceneDisplayWelshDates = false
    public var shouldCurrentSceneDisplayWelshDates: Bool {
        get {
            return stubbedShouldCurrentSceneDisplayWelshDates
        }
        set {
            invokedShouldCurrentSceneDisplayWelshDates = true
            stubbedShouldCurrentSceneDisplayWelshDates = newValue
        }
    }

    var invokedCurrentLocaleGetter = false
    var invokedCurrentLocaleGetterCount = 0
    var stubbedCurrentLocale: Locale?

    public var currentLocale: Locale {
        invokedCurrentLocaleGetter = true
        invokedCurrentLocaleGetterCount += 1
        return stubbedCurrentLocale ?? instance.currentLocale
    }

    var invokedUsPosixLocaleGetter = false
    var invokedUsPosixLocaleGetterCount = 0
    var stubbedUsPosixLocale: Locale?

    public var usPosixLocale: Locale {
        invokedUsPosixLocaleGetter = true
        invokedUsPosixLocaleGetterCount += 1
        return stubbedUsPosixLocale ?? instance.usPosixLocale
    }

    var invokedBritishTimeZoneGetter = false
    var invokedBritishTimeZoneGetterCount = 0
    var stubbedBritishTimeZone: TimeZone?

    public var britishTimeZone: TimeZone {
        invokedBritishTimeZoneGetter = true
        invokedBritishTimeZoneGetterCount += 1
        return stubbedBritishTimeZone ?? instance.britishTimeZone
    }

    var invokedCurrentDateGetter = false
    var invokedCurrentDateGetterCount = 0
    var stubbedCurrentDate: Date?

    public var currentDate: Date {
        invokedCurrentDateGetter = true
        invokedCurrentDateGetterCount += 1
        return stubbedCurrentDate ?? instance.currentDate
    }

    var invokedUtcTimeZoneGetter = false
    var invokedUtcTimeZoneGetterCount = 0
    var stubbedUtcTimeZone: String?

    public var utcTimeZone: String {
        invokedUtcTimeZoneGetter = true
        invokedUtcTimeZoneGetterCount += 1
        return stubbedUtcTimeZone ?? instance.utcTimeZone
    }

    var invokedCurrentTimeZoneGetter = false
    var invokedCurrentTimeZoneGetterCount = 0
    var stubbedCurrentTimeZone: TimeZone?

    public var currentTimeZone: TimeZone {
        invokedCurrentTimeZoneGetter = true
        invokedCurrentTimeZoneGetterCount += 1
        return stubbedCurrentTimeZone ?? instance.currentTimeZone
    }

    var invokedDMMMMFormatterGetter = false
    var invokedDMMMMFormatterGetterCount = 0
    var stubbedDMMMMFormatter: Foundation.DateFormatter?

    public var dMMMMFormatter: Foundation.DateFormatter {
        invokedDMMMMFormatterGetter = true
        invokedDMMMMFormatterGetterCount += 1
        return stubbedDMMMMFormatter ?? instance.dMMMMFormatter
    }

    var invokedYyyyMMddFormatterGetter = false
    var invokedYyyyMMddFormatterGetterCount = 0
    var stubbedYyyyMMddFormatter: Foundation.DateFormatter?

    public var yyyyMMddFormatter: Foundation.DateFormatter {
        invokedYyyyMMddFormatterGetter = true
        invokedYyyyMMddFormatterGetterCount += 1
        return stubbedYyyyMMddFormatter ?? instance.yyyyMMddFormatter
    }

    var invokedLongMonthYearFormatterGetter = false
    var invokedLongMonthYearFormatterGetterCount = 0
    var stubbedLongMonthYearFormatter: Foundation.DateFormatter?

    public var longMonthYearFormatter: Foundation.DateFormatter {
        invokedLongMonthYearFormatterGetter = true
        invokedLongMonthYearFormatterGetterCount += 1
        return stubbedLongMonthYearFormatter ?? instance.longMonthYearFormatter
    }

    var invokedLongDateFormatterGetter = false
    var invokedLongDateFormatterGetterCount = 0
    var stubbedLongDateFormatter: Foundation.DateFormatter?

    public var longDateFormatter: Foundation.DateFormatter {
        invokedLongDateFormatterGetter = true
        invokedLongDateFormatterGetterCount += 1
        return stubbedLongDateFormatter ?? instance.longDateFormatter
    }

    var invokedLongDateBritishTimeZoneFormatterGetter = false
    var invokedLongDateBritishTimeZoneFormatterGetterCount = 0
    var stubbedLongDateBritishTimeZoneFormatter: Foundation.DateFormatter?

    public var longDateBritishTimeZoneFormatter: Foundation.DateFormatter {
        invokedLongDateBritishTimeZoneFormatterGetter = true
        invokedLongDateBritishTimeZoneFormatterGetterCount += 1
        return stubbedLongDateBritishTimeZoneFormatter ?? instance.longDateBritishTimeZoneFormatter
    }

    var invokedLongDateUTCDateFormatterGetter = false
    var invokedLongDateUTCDateFormatterGetterCount = 0
    var stubbedLongDateUTCDateFormatter: Foundation.DateFormatter?

    public var longDateUTCDateFormatter: Foundation.DateFormatter {
        invokedLongDateUTCDateFormatterGetter = true
        invokedLongDateUTCDateFormatterGetterCount += 1
        return stubbedLongDateUTCDateFormatter ?? instance.longDateUTCDateFormatter
    }

    var invokedMediumDateBritishTimeZoneFormatterGetter = false
    var invokedMediumDateBritishTimeZoneFormatterGetterCount = 0
    var stubbedMediumDateBritishTimeZoneFormatter: Foundation.DateFormatter?

    public var mediumDateBritishTimeZoneFormatter: Foundation.DateFormatter {
        invokedMediumDateBritishTimeZoneFormatterGetter = true
        invokedMediumDateBritishTimeZoneFormatterGetterCount += 1
        return stubbedMediumDateBritishTimeZoneFormatter ?? instance.mediumDateBritishTimeZoneFormatter
    }

    var invokedTimeFormatterGetter = false
    var invokedTimeFormatterGetterCount = 0
    var stubbedTimeFormatter: Foundation.DateFormatter?

    public var timeFormatter: Foundation.DateFormatter {
        invokedTimeFormatterGetter = true
        invokedTimeFormatterGetterCount += 1
        return stubbedTimeFormatter ?? instance.timeFormatter
    }

    var invokedRelativeDateFormatterGetter = false
    var invokedRelativeDateFormatterGetterCount = 0
    var stubbedRelativeDateFormatter: Foundation.DateFormatter?

    public var relativeDateFormatter: Foundation.DateFormatter {
        invokedRelativeDateFormatterGetter = true
        invokedRelativeDateFormatterGetterCount += 1
        return stubbedRelativeDateFormatter ?? instance.relativeDateFormatter
    }

    var invokedIsoDateFormatterGetter = false
    var invokedIsoDateFormatterGetterCount = 0
    var stubbedIsoDateFormatter: Foundation.DateFormatter?

    public var isoDateFormatter: Foundation.DateFormatter {
        invokedIsoDateFormatterGetter = true
        invokedIsoDateFormatterGetterCount += 1
        return stubbedIsoDateFormatter ?? instance.isoDateFormatter
    }

    var invokedRfc3339DateTimeFormatterGetter = false
    var invokedRfc3339DateTimeFormatterGetterCount = 0
    var stubbedRfc3339DateTimeFormatter: Foundation.DateFormatter?

    public var rfc3339DateTimeFormatter: Foundation.DateFormatter {
        invokedRfc3339DateTimeFormatterGetter = true
        invokedRfc3339DateTimeFormatterGetterCount += 1
        return stubbedRfc3339DateTimeFormatter ?? instance.rfc3339DateTimeFormatter
    }

    var invokedRfc3339DateFormatterGetter = false
    var invokedRfc3339DateFormatterGetterCount = 0
    var stubbedRfc3339DateFormatter: Foundation.DateFormatter?

    public var rfc3339DateFormatter: Foundation.DateFormatter {
        invokedRfc3339DateFormatterGetter = true
        invokedRfc3339DateFormatterGetterCount += 1
        return stubbedRfc3339DateFormatter ?? instance.rfc3339DateFormatter
    }

    var invokedYearAndMonthDateFormatterGetter = false
    var invokedYearAndMonthDateFormatterGetterCount = 0
    var stubbedYearAndMonthDateFormatter: Foundation.DateFormatter?

    public var yearAndMonthDateFormatter: Foundation.DateFormatter {
        invokedYearAndMonthDateFormatterGetter = true
        invokedYearAndMonthDateFormatterGetterCount += 1
        return stubbedYearAndMonthDateFormatter ?? instance.yearAndMonthDateFormatter
    }

    var invokedLongMonthAndYearDateFormatterGetter = false
    var invokedLongMonthAndYearDateFormatterGetterCount = 0
    var stubbedLongMonthAndYearDateFormatter: Foundation.DateFormatter?

    public var longMonthAndYearDateFormatter: Foundation.DateFormatter {
        invokedLongMonthAndYearDateFormatterGetter = true
        invokedLongMonthAndYearDateFormatterGetterCount += 1
        return stubbedLongMonthAndYearDateFormatter ?? instance.longMonthAndYearDateFormatter
    }

    var invokedLongDayAndMonthDateFormatterGetter = false
    var invokedLongDayAndMonthDateFormatterGetterCount = 0
    var stubbedLongDayAndMonthDateFormatter: Foundation.DateFormatter?

    public var longDayAndMonthDateFormatter: Foundation.DateFormatter {
        invokedLongDayAndMonthDateFormatterGetter = true
        invokedLongDayAndMonthDateFormatterGetterCount += 1
        return stubbedLongDayAndMonthDateFormatter ?? instance.longDayAndMonthDateFormatter
    }

    var invokedYearDateFormatterGetter = false
    var invokedYearDateFormatterGetterCount = 0
    var stubbedYearDateFormatter: Foundation.DateFormatter?

    public var yearDateFormatter: Foundation.DateFormatter {
        invokedYearDateFormatterGetter = true
        invokedYearDateFormatterGetterCount += 1
        return stubbedYearDateFormatter ?? instance.yearDateFormatter
    }

    var invokedForwardSlashDateFormatterGetter = false
    var invokedForwardSlashDateFormatterGetterCount = 0
    var stubbedForwardSlashDateFormatter: Foundation.DateFormatter?

    public var forwardSlashDateFormatter: Foundation.DateFormatter {
        invokedForwardSlashDateFormatterGetter = true
        invokedForwardSlashDateFormatterGetterCount += 1
        return stubbedForwardSlashDateFormatter ?? instance.forwardSlashDateFormatter
    }

    var invokedHttpHeaderDateFormatterGetter = false
    var invokedHttpHeaderDateFormatterGetterCount = 0
    var stubbedHttpHeaderDateFormatter: Foundation.DateFormatter?

    public var httpHeaderDateFormatter: Foundation.DateFormatter {
        invokedHttpHeaderDateFormatterGetter = true
        invokedHttpHeaderDateFormatterGetterCount += 1
        return stubbedHttpHeaderDateFormatter ?? instance.httpHeaderDateFormatter
    }

    var invokedJsonISO8601DateFormatterGetter = false
    var invokedJsonISO8601DateFormatterGetterCount = 0
    var stubbedJsonISO8601DateFormatter: Foundation.DateFormatter?

    public var jsonISO8601DateFormatter: Foundation.DateFormatter {
        invokedJsonISO8601DateFormatterGetter = true
        invokedJsonISO8601DateFormatterGetterCount += 1
        return stubbedJsonISO8601DateFormatter ?? instance.jsonISO8601DateFormatter
    }

    var invokedYyyyMMddDateToDate = false
    var invokedYyyyMMddDateToDateCount = 0
    var invokedYyyyMMddDateToDateParameters: (dateString: String, Void)?
    var invokedYyyyMMddDateToDateParametersList = [(dateString: String, Void)]()
    var stubbedYyyyMMddDateToDateResult: Date?

    public func yyyyMMddDateToDate(_ dateString: String) -> Date {
        invokedYyyyMMddDateToDate = true
        invokedYyyyMMddDateToDateCount += 1
        invokedYyyyMMddDateToDateParameters = (dateString, ())
        invokedYyyyMMddDateToDateParametersList.append((dateString, ()))
        return stubbedYyyyMMddDateToDateResult ?? instance.yyyyMMddDateToDate(dateString)
    }

    var invokedRelativeReadableDate = false
    var invokedRelativeReadableDateCount = 0
    var invokedRelativeReadableDateParameters: (date: Date, Void)?
    var invokedRelativeReadableDateParametersList = [(date: Date, Void)]()
    var stubbedRelativeReadableDateResult: String?

    public func relativeReadableDate(_ date: Date) -> String {
        invokedRelativeReadableDate = true
        invokedRelativeReadableDateCount += 1
        invokedRelativeReadableDateParameters = (date, ())
        invokedRelativeReadableDateParametersList.append((date, ()))
        return stubbedRelativeReadableDateResult ?? instance.relativeReadableDate(date)
    }

    var invokedIsoDate = false
    var invokedIsoDateCount = 0
    var invokedIsoDateParameters: (yyyyMMddDate: String, Void)?
    var invokedIsoDateParametersList = [(yyyyMMddDate: String, Void)]()
    var stubbedIsoDateResult: Date?

    public func isoDate(_ yyyyMMddDate: String) -> Date {
        invokedIsoDate = true
        invokedIsoDateCount += 1
        invokedIsoDateParameters = (yyyyMMddDate, ())
        invokedIsoDateParametersList.append((yyyyMMddDate, ()))
        return stubbedIsoDateResult ?? instance.isoDate(yyyyMMddDate)
    }

    var invokedEpochDate = false
    var invokedEpochDateCount = 0
    var invokedEpochDateParameters: (milliseconds: Double, Void)?
    var invokedEpochDateParametersList = [(milliseconds: Double, Void)]()
    var stubbedEpochDateResult: Date?

    public func epochDate(milliseconds: Double) -> Date {
        invokedEpochDate = true
        invokedEpochDateCount += 1
        invokedEpochDateParameters = (milliseconds, ())
        invokedEpochDateParametersList.append((milliseconds, ()))
        return stubbedEpochDateResult ?? instance.epochDate(milliseconds: milliseconds)
    }

    var invokedHttpHeaderDate = false
    var invokedHttpHeaderDateCount = 0
    var invokedHttpHeaderDateParameters: (dateString: String, Void)?
    var invokedHttpHeaderDateParametersList = [(dateString: String, Void)]()
    var stubbedHttpHeaderDateResult: Date?

    public func httpHeaderDate(_ dateString: String) -> Date? {
        invokedHttpHeaderDate = true
        invokedHttpHeaderDateCount += 1
        invokedHttpHeaderDateParameters = (dateString, ())
        invokedHttpHeaderDateParametersList.append((dateString, ()))
        return stubbedHttpHeaderDateResult ?? instance.httpHeaderDate(dateString)
    }

    var invokedDateAtTimeFormat = false
    var invokedDateAtTimeFormatCount = 0
    var invokedDateAtTimeFormatParameters: (date: Date, Void)?
    var invokedDateAtTimeFormatParametersList = [(date: Date, Void)]()
    var stubbedDateAtTimeFormatResult: String?

    public func dateAtTimeFormat(date: Date) -> String {
        invokedDateAtTimeFormat = true
        invokedDateAtTimeFormatCount += 1
        invokedDateAtTimeFormatParameters = (date, ())
        invokedDateAtTimeFormatParametersList.append((date, ()))
        return stubbedDateAtTimeFormatResult ?? instance.dateAtTimeFormat(date: date)
    }
}
// swiftlint:enable identifier_name
