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

import UIKit
import ios_core_library

open class MockApplicationStateService: ApplicationStateService {
    public var badgeCount: Int = 0

    public var returnState: UIApplication.State

    public var current: UIApplication.State {
        return returnState
    }

    public var currentBadgeCount: Int?

    public var badgeCount: Int {
        get {
            currentBadgeCount ?? 0
        } set {
            currentBadgeCount = newValue
        }
    }

    public init(_ state: UIApplication.State?=nil) {
        returnState = state ?? .active
    }
}
