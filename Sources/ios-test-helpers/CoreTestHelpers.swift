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

import XCTest

public class CoreTestHelpers {

    public static func delay(_ delayInSeconds: TimeInterval = 1.0, closure: @escaping (() -> Void)) {
        let delayInMilliSeconds = Int(delayInSeconds * 1000)
        let nanoseconds = DispatchTime.now() + DispatchTimeInterval.milliseconds(delayInMilliSeconds)
        DispatchQueue.main.asyncAfter(deadline: nanoseconds, execute: closure)
    }
}
