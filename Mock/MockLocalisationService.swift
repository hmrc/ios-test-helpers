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
import ios_core_library

open class MockLocalisationService: MobileCore.Localisation.Service {
    var override_shouldShowLanguageSwitcher: Bool = false
    var didSet_shouldShowLanguageSwitcher: Bool?
    override open var shouldShowLanguageSwitcher: Bool {
        get { override_shouldShowLanguageSwitcher }
        set { didSet_shouldShowLanguageSwitcher = newValue }
    }

    var override_shouldShowContentInWelsh: Bool = false
    var didSet_shouldShowContentInWelsh: Bool?
    override open var shouldShowContentInWelsh: Bool {
        get { override_shouldShowContentInWelsh }
        set { didSet_shouldShowContentInWelsh = newValue }
    }
}
