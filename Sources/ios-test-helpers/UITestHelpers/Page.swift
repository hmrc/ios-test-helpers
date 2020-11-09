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
import SBTUITestTunnelClient
import XCTest

// swiftlint:disable type_body_length file_length
public class Page {
    //swiftlint:disable duplicate_enum_cases
    enum PageError: Error {
        case notFound(elementWithIdentifier: String)
        case notFound(elementWithText: String)
    }
    //swiftlint:enable duplicate_enum_cases

    let app = XCUIApplication()
    let testCase: BaseUITest
    let pageName: String

    class var exists: Bool { false }

    var uniqueElement: XCUIElement?
    var uniquePartialText: String?

    init(testCase: BaseUITest, pageName: String = "Page", uniqueElement: XCUIElement? = nil, uniquePartialText: String? = nil) {
        self.testCase = testCase
        self.pageName = pageName
        self.uniqueElement = uniqueElement
        self.uniquePartialText = uniquePartialText
    }

    /// This function waits for a unique element to displayed in a `Page` before continuing with the integration test
    /// The unique element is defined with the `Page` object itself
    ///
    /// ```
    /// Page.await()
    /// ```
    ///
    /// - Warning: It will hang trying to find a unique element until the timeout period has expired in case on animations
    @discardableResult public func await(file: StaticString = #file, line: UInt = #line) -> Self {
        if let element = uniqueElement {
            let existsPredicate = NSPredicate(format: "exists == true")
            let expectation = testCase.expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
            let result = XCTWaiter().wait(for: [expectation], timeout: Test.Timeout)
            if result != .completed {
                XCTFail("Could not find unique element '\(element)' on '\(self.pageName)'", file: file, line: line)
            }
        } else if let uniquePartialText = uniquePartialText {
            confirmTextIsDisplayed(uniquePartialText, allowPartialMatch: true)
        }
        return self
    }

    // MARK: - Text Input
    /// This function checks for the existance of a string within a text view defined by an accessibility id
    ///
    /// ```
    /// .confirmTextViewIdPopulated("text_accessibility_id", text: "text to check")
    /// ```
    ///
    /// - Parameter textViewId: Accessibility ID of the text view
    /// - Parameter text: Text to be checked
    @discardableResult
    public func confirmTextViewIsPopulated(
        _ textViewId: String,
        text: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        guard let element = element(textViewId, type: .textView) else {
            XCTFail("Didn't find textView \(textViewId)", file: file, line: line)
            return self
        }
        XCTAssertTrue(element.exists, "textView: \(textViewId) not populated")
        XCTAssertEqual(element.value as? String, text)
        return self
    }

    /// This function types a given string into a text field defined with an accessibility id
    ///
    /// ```
    /// .typeIntoTextField("text_accessibility_id", text: "text to type")
    /// ```
    ///
    /// - Parameter id: Accessibility ID of the text field
    /// - Parameter text: Text to be checked
    /// - Parameter clearFirst: Boolean to say whether or not to clear the text field before typing
    @discardableResult
    public func typeIntoTextField(
        _ id: String,
        text: String,
        clearFirst: Bool = false,
        file: StaticString = #file,
        line: UInt = #line) -> Self {

        let element = app.textFields[id]
        typeIntoElement(element: element, text: text, clearFirst: clearFirst, file: file, line: line)
        return self
    }

    /// This function types a given string into a text view defined with an accessibility id
    ///
    /// ```
    /// .typeIntoTextView("text_accessibility_id", text: "text to type")
    /// ```
    ///
    /// - Parameter id: Accessibility ID of the text view
    /// - Parameter text: Text to be checked
    /// - Parameter clearFirst: Boolean to say whether or not to clear the text view before typing
    @discardableResult
    public func typeIntoTextView(
        _ id: String,
        text: String,
        clearFirst: Bool = false,
        file: StaticString = #file,
        line: UInt = #line) -> Self {

        let element = app.textViews[id]
        typeIntoElement(element: element, text: text, clearFirst: clearFirst, file: file, line: line)
        return self
    }

    @discardableResult
    public func performSnapshot(_ name: String, file: StaticString = #file, line: UInt = #line) -> Self {
        #if SCREENSHOT
        sleep(2)
        hideContinuousPathIntroductionViewIfVisible(file: file, line: line)
        sleep(2)
        snapshot(name, timeWaitingForIdle: 1)
        #else
        XCTFail("performSnapshot called outside of SCREENSHOT target")
        #endif
        return self
    }

    // MARK: - Navigation Bar

    /// This function checks a given string against a navigation bar title
    ///
    /// ```
    /// .confirmNavigationBarTextMatches("text to check")
    /// ```
    ///
    /// - Parameter text: Text to be checked
    @discardableResult
    public func confirmNavigationBarTextMatches(
        _ text: String,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {

        XCTAssertTrue(app.navigationBars[text].exists, "Navigation bar doesn't match \(text)", file: file, line: line)
        return self
    }

    /// Taps a button defined by text
    ///
    /// ```
    /// .tapNavigationBackButton()
    /// ```
    ///
    /// - Parameter waitForQuiescence: Wait for the app to become idle
    @discardableResult
    public func tapNavigationBackButton(waitForQuiescence: Bool = true, file: StaticString = #file, line: UInt = #line) -> Self {
        // swiftlint:disable:next empty_count
        guard app.navigationBars.buttons.count > 0 else {
            XCTFail("Could not find back button", file: file, line: line)
            return self
        }
        if !waitForQuiescence {
            disableWaitForIdle()
        }
        app.navigationBars.buttons.element(boundBy: 0).tap()
        if !waitForQuiescence {
            enableWaitForIdle()
        }
        return self
    }

    // MARK: - Static Text

    /// This function checks a given string is displayed somewhere on the page
    ///
    /// ```
    /// .confirmTextIsDisplayed("text to check")
    /// ```
    ///
    /// - warning: By default this doesn't check if the text is currently visible or not
    ///
    /// - Parameter text: Text to be checked
    /// - Parameter count: Number of instances of text
    /// - Parameter allowPartialMatch: Allows the given text to only be part of the whole
    /// - Parameter onScreen: Checks whether the text is currently on the screen or not
    @discardableResult
    public func confirmTextIsDisplayed(
        _ text: String,
        count: Int = -1,
        allowPartialMatch: Bool = false,
        onScreen: Bool = false,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {
        if allowPartialMatch {
            XCTAssertTrue((partialStaticTextIsVisibleMultipleTimes(text, count: count) ||
                partialTextViewIsVisibleMultipleTimes(text, count: count)),
                          "Didn't find text: \(text)", file: file, line: line)
        } else {
            XCTAssertTrue((staticTextIsVisibleMultipleTimes(text, count: count) ||
                textViewIsVisibleMultipleTimes(text, count: count)),
                          "Didn't find text: \(text)", file: file, line: line)
        }
        return self
    }

    /// This function checks a given string is displayed in a bullet somewhere on the page
    ///
    /// ```
    /// .confirmBulletIsDisplayed("text to check")
    /// ```
    ///
    /// - warning: By default this doesn't check if the text is currently visible or not
    ///
    /// - Parameter text: Text to be checked
    @discardableResult
    public func confirmBulletIsDisplayed(
        _ text: String,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {
        confirmTextIsDisplayed("•; \(text)", in: file, at: line)
        return self
    }

    /// This function checks a given string is displayed within a specific label
    ///
    /// ```
    /// .confirmLabelAndValueAreDisplayd("accessibility_id", "text to check")
    /// ```
    ///
    /// - warning: This doesn't check if the text is currently visible or not
    ///
    /// - Parameter label: Accessibility id of label
    /// - Parameter text: Text to be checked
    @discardableResult
    public func confirmLabelAndValueAreDisplayed(
        _ label: String,
        _ value: String,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {

        let otherElements = app.otherElements.containing(.staticText, identifier: label).allElementsBoundByIndex
        let parentElements = otherElements.filter { (otherElement) -> Bool in
            //swiftlint:disable:next empty_count
            otherElement.children(matching: .staticText).containing(.staticText, identifier: label).count > 0
        }

        guard let parentElement = parentElements.first else {
            XCTFail("Didn't find parent of label: \(label)", file: file, line: line)
            return self
        }

        //swiftlint:disable:next empty_count
        if parentElement.children(matching: .staticText).containing(.staticText, identifier: value).count == 0 {
            XCTFail("Didn't find associated value: \(value)", file: file, line: line)
        }

        return self
    }

    /// This function checks a given string is displayed within a specific label
    ///
    /// ```
    /// .confirmTextIsDisplayed("text to check", "text_field_accessibility_id")
    /// ```
    ///
    /// - warning: This doesn't check if the text is currently visible or not
    ///
    /// - Parameter text: Text to be checked
    /// - Parameter textFieldId: Accessibility id of text field
    @discardableResult
    public func confirmTextIsDisplayed(
        _ text: String,
        in textFieldId: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {

        let element = app.staticTexts[textFieldId]

        XCTAssertTrue(element.exists, file: file, line: line)
        XCTAssertEqual(element.label, text, file: file, line: line)
        return self
    }

    /// This function checks a given string is not displayed in any label
    ///
    /// ```
    /// .confirmTextIsNotDisplayed("text to check")
    /// ```
    ///
    /// - Parameter text: Text to be checked
    @discardableResult
    public func confirmTextIsNotDisplayed(
        _ text: String,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {
        XCTAssertFalse(
            (staticTextIsVisible(text) || textViewIsVisible(text)),
            "Unexpectedly found text: \(text)",
            file: file,
            line: line
        )
        return self
    }

    /// This function checks a given string is displayed within a webview
    ///
    /// ```
    /// .confirmWebViewTextIsDisplayed("text to check")
    /// ```
    ///
    /// - Parameter text: Text to be checked
    @discardableResult
    public func confirmWebViewTextIsDisplayed(
        _ text: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {

        let element = app.webViews.firstMatch.staticTexts[text]
        if element.waitForExistence(timeout: Test.Timeout) {
            awaitElement(type: .staticText, text: text)
        } else {
            XCTFail("Web view with text: '\(text)' not found")
        }
        return self
    }

    // MARK: - Buttons

    /// This function checks a button is displayed with text
    ///
    /// ```
    /// .confirmButtonIsDisplayed("text to check")
    /// ```
    ///
    /// - Parameter text: Text to be checked
    /// - Parameter onScreen: Bool for if the button should be currently visible
    /// - Parameter allowPartialMatch: The text doesn't have to match the button exactly
    @discardableResult
    public func confirmButtonIsDisplayed(
        _ text: String,
        onScreen: Bool = false,
        allowPartialMatch: Bool = false,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {

        if allowPartialMatch {
            guard let element = elementPartialMatch(text, type: .button) else {
                XCTFail("Didn't find button: \(text)", file: file, line: line)
                return self
            }
            XCTAssertTrue(elementExistsAndIsVisible(element, onScreen: onScreen), "\(element) not found")
        } else {
            guard let element = element(text, type: .button, onScreen: onScreen) else {
                XCTFail("Didn't find button: \(text)", file: file, line: line)
                return self
            }
            XCTAssertTrue(elementExistsAndIsVisible(element, onScreen: onScreen), "\(element) not found")
        }
        return self
    }

    /// This function checks a given string is displayed within a webview
    ///
    /// ```
    /// .confirmRowIsDisplayed(accessibilityLabel: "id_of_row")
    /// ```
    ///
    /// - Parameter accessibilityLabel: Accessibility label of row
    /// - Parameter onScreen: Should the row be currently displayed
    @discardableResult
    public func confirmRowIsDisplayed(
        accessibilityLabel: String,
        onScreen: Bool = false,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {

        confirmButtonIsDisplayed(
            accessibilityLabel,
            onScreen: onScreen,
            in: file,
            at: line
        )
    }

    // MARK: - Buttons

    /// This function checks a button defined by text is not displayed
    ///
    /// ```
    /// .confirmButtonIsNotDisplayed("text to check")
    /// ```
    ///
    /// - Parameter text: Text to be checked
    @discardableResult
    public func confirmButtonIsNotDisplayed(_ text: String, in file: StaticString = #file, at line: UInt = #line) -> Self {
        guard let element = element(text, type: .button) else { return self }
        XCTAssertFalse(element.exists, "Unexpectedly found button: \(text)", file: file, line: line)
        return self
    }

    /// This function checks a button defined by text is not enabled
    ///
    /// ```
    /// .confirmButtonIsDisabled("text to check")
    /// ```
    ///
    /// - Parameter text: Text to be checked
    @discardableResult
    public func confirmButtonIsDisabled(_ text: String, file: StaticString = #file, line: UInt = #line) -> Self {
        guard let element = element(text, type: .button) else {
            XCTFail("Didn't find button: \(text)", file: file, line: line)
            return self
        }
        XCTAssertTrue(element.exists, file: file, line: line)
        XCTAssertFalse(element.isEnabled, file: file, line: line)
        return self
    }

    /// This function checks a button defined by text is enabled
    ///
    /// ```
    /// .confirmButtonIsEnabled("text to check")
    /// ```
    ///
    /// - Parameter text: Text to be checked
    @discardableResult
    public func confirmButtonIsEnabled(
        _ text: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        guard let element = element(text, type: .button) else {
            XCTFail("Didn't find button: \(text)", file: file, line: line)
            return self
        }
        XCTAssertTrue(element.exists, "Didn't find button: \(text)", file: file, line: line)
        XCTAssertTrue(element.isEnabled, "Button wasn't enabled: \(text)", file: file, line: line)
        return self
    }

    /// Taps a cell defined by text
    ///
    /// ```
    /// .tapCellWithLabel("text to check")
    /// ```
    ///
    /// - Parameter text: Text to be checked
    /// - Parameter onScreen: Should only the button if currently on screen
    /// - Parameter waitForQuiescence: Wait for the app to become idle
    @discardableResult
    public func tapCellWithLabel(
        _ text: String,
        onScreen: Bool = false,
        waitForQuiescence: Bool = true,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {

        if !waitForQuiescence {
            disableWaitForIdle()
        }
        tapElementWithLabel(text, type: .cell, onScreen: onScreen, in: file, at: line)
        if !waitForQuiescence {
            enableWaitForIdle()
        }
        return self
    }

    /// Taps a button defined by text
    ///
    /// ```
    /// .tapButtonWithLabel("text to check")
    /// ```
    ///
    /// - Parameter text: Text to be checked
    /// - Parameter onScreen: Should only the button if currently on screen
    /// - Parameter waitForQuiescence: Wait for the app to become idle
    @discardableResult
    public func tapButtonWithLabel(
        _ text: String,
        onScreen: Bool = false,
        waitForQuiescence: Bool = true,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {

        if !waitForQuiescence {
            disableWaitForIdle()
        }
        tapElementWithLabel(text, type: .button, onScreen: onScreen, in: file, at: line)
        if !waitForQuiescence {
            enableWaitForIdle()
        }
        return self
    }

    /// Scrolls screen to a button defined by text
    ///
    /// ```
    /// .scrollDownToButtonWithLabel("text to check")
    /// ```
    ///
    /// - Parameter text: Text to be checked
    @discardableResult
    public func scrollDownToButtonWithLabel(_ text: String, file: StaticString = #file, line: UInt = #line) -> Self {
        guard let element = element(text, type: .button) else {
            XCTFail("Didn't find button: \(text)", file: file, line: line)
            return self
        }
        app.scrollDownTo(element: element)
        return self
    }

    /// Scrolls screen down
    ///
    /// ```
    /// .scrollDown())
    /// ```
    ///
    @discardableResult
    public func scrollDown(file: StaticString = #file, line: UInt = #line) -> Self {
        app.scrollDown()
        return self
    }

    /// Scrolls screen to a text view defined by an accessibility identifier
    ///
    /// ```
    /// .scrollDownToTextViewWithIdentifier("identifier")
    /// ```
    ///
    /// - Parameter identifier: Accessibility identifier of text view
    @discardableResult
    public func scrollDownToTextViewWithIdentifier(_ identifier: String, file: StaticString = #file, line: UInt = #line) -> Self {
        let element = app.textViews[identifier]
        app.scrollDownTo(element: element)
        return self
    }

    /// Scrolls a collection view defined by an accessibility identifier to a cell
    ///
    /// ```
    /// .scrollCollectionView(identifier: "identifier", to: "cell_identifier")
    /// ```
    ///
    /// - Parameter identifier: Accessibility identifier of collection view
    /// - Parameter cellIdentifier: Accessibility identifier of cell
    @discardableResult
    public func scrollCollectionView(identifier: String, to cellIdentifier: String, maxScrolls: Int = 5) -> Self {
        let collectionView = app.collectionViews.matching(identifier: identifier)
        let element = collectionView.cells[cellIdentifier]
        app.scrollDownTo(element: element, maxScrolls: maxScrolls)
        return self
    }

    /// Waits for a defined element to appear within the view
    ///
    /// ```
    /// .awaitElement(app.staticText["label text"])
    /// ```
    ///
    /// - Warning: This doesn't wait for it to appear on screen, just load within the view
    ///
    /// - Parameter element: Element to wait for
    @discardableResult
    public func awaitElement(
        _ element: XCUIElement,
        file: StaticString = #file,
        line: UInt = #line) -> Self {

        let existsPredicate = NSPredicate(format: "exists == true")
        let expectation = testCase.expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        let result = XCTWaiter().wait(for: [expectation], timeout: Test.Timeout)
        if result != .completed {
            XCTAssertTrue(
                element.exists,
                "Could not find element '\(element)' on '\(self.pageName)'",
                file: file,
                line: line
            )

        }

        return self
    }

    // MARK: - Radio Buttons

    /// Checks whether radio button is displayed
    ///
    /// ```
    /// .confirmRadioButtonIsDisplayed("text to check")
    /// ```
    ///
    /// - Warning: onScreen defaults to false
    ///
    /// - Parameter text: text of radio button
    /// - Parameter onScreen: Checks whether it's current within the view or not
    @discardableResult
    public func confirmRadioButtonIsDisplayed(
        _ text: String,
        onScreen: Bool = false,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {

        let elementType: XCUIElement.ElementType = {
            if #available(iOS 13.0, *) {
                return .button
            } else {
                return .other
            }
        }()

        guard let element = element(text, type: elementType, onScreen: onScreen) else {
            XCTFail("Didn't find radio button: \(text)", file: file, line: line)
            return self
        }

        XCTAssertTrue(elementExistsAndIsVisible(element, onScreen: onScreen), "\(element) not found")
        return self
    }

    /// Taps radio button with given text
    ///
    /// ```
    /// .tapRadioButtonWithLabel("text to check")
    /// ```
    ///
    /// - Warning: onScreen defaults to false
    ///
    /// - Parameter text: text of radio button
    /// - Parameter onScreen: Checks whether it's current within the view or not
    @discardableResult
    public func tapRadioButtonWithLabel(
        _ text: String,
        onScreen: Bool = false,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {
        if #available(iOS 13.0, *) {
            return tapElementWithLabel(text, type: .button, onScreen: onScreen, in: file, at: line)
        } else {
            return tapElementWithLabel(text, type: .other, onScreen: onScreen, in: file, at: line)
        }
    }

    // MARK: - Images

    /// Checks image of name is displayed
    ///
    /// ```
    /// .confirmImageIsDisplayed("name of image")
    /// ```
    ///
    /// - Warning: onScreen defaults to false
    ///
    /// - Parameter text: Name of image
    /// - Parameter onScreen: Checks whether it's current within the view or not
    @discardableResult
    public func confirmImageIsDisplayed(
        _ text: String,
        onScreen: Bool = false,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {

        guard let element = element(text, type: .image, onScreen: onScreen) else {
            XCTFail("Didn't find image: \(text)", file: file, line: line)
            return self
        }

        XCTAssertTrue(elementExistsAndIsVisible(element, onScreen: onScreen), "\(element) not found")
        return self
    }

    // MARK: - Sheets

    /// Checks action sheet appears with a title
    ///
    /// ```
    /// .confirmSheetIsDisplayed("name of image")
    /// ```
    ///
    /// - Parameter title: title of action sheet
    @discardableResult
    public func confirmSheetIsDisplayed(_ title: String, in file: StaticString = #file, at line: UInt = #line) -> Self {
        let predicate = NSPredicate(format: "label == %@", title)
        let matchingElement = app.descendants(matching: .sheet).element(matching: predicate)
        let expectation = testCase.expectation(for: predicate, evaluatedWith: matchingElement, handler: nil)
        let result = XCTWaiter().wait(for: [expectation], timeout: Test.Timeout)
        if result != .completed {
            XCTAssertTrue(matchingElement.exists, "Did not find sheet with title: \(title)", file: file, line: line)
        }
        return self
    }

    /// Checks share sheet appears
    ///
    /// ```
    /// .confirmShareSheetIsDisplayed()
    /// ```
    ///
    @discardableResult
    public func confirmShareSheetIsDisplayed(file: StaticString = #file, line: UInt = #line) -> Self {
        let predicate = NSPredicate(format: "identifier == %@", "ActivityListView")
        let matchingElement = app.descendants(matching: .other).element(matching: predicate)
        let expectation = testCase.expectation(for: predicate, evaluatedWith: matchingElement, handler: nil)
        let result = XCTWaiter().wait(for: [expectation], timeout: Test.Timeout)
        if result != .completed {
            XCTAssertTrue(matchingElement.exists, "Did not find share sheet", file: file, line: line)
        }
        return self
    }

    /// Closes open share sheets
    ///
    /// ```
    /// .closeShareSheet()
    /// ```
    ///
    @discardableResult
    public func closeShareSheet(file: StaticString = #file, line: UInt = #line) -> Self {
        let popoverDismissRegion = app.otherElements["PopoverDismissRegion"]

        if let closeButton = element("Close", type: .button, onScreen: true), closeButton.isEnabled {
            closeButton.tap()
            return self
        } else if elementExistsAndIsVisible(popoverDismissRegion) {
            popoverDismissRegion.tap()
            return self
        } else {
            XCTFail("Cannot close share sheet", file: file, line: line)
            return self
        }
    }

    // MARK: - Alerts

    /// Checks alert appears with a title, body, and icon
    ///
    /// ```
    /// .confirmAlertIsDisplayed("title of alert", body: nil, isIconAlert: false)
    /// ```
    ///
    /// - Warning: body defaults to nil (not checked)
    /// - Warning: isIconAlert defaults to false (not checked)
    ///
    /// - Parameter title: title of alert
    /// - Parameter body: Body text of alert
    /// - Parameter isIconAlert: Checks if alert contains an icon
    @discardableResult
    public func confirmAlertIsDisplayed(
        _ title: String,
        body: String? = nil,
        isIconAlert: Bool = false,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {
        let predicateTitle: NSPredicate = {
            if isIconAlert {
                return NSPredicate(format: "label MATCHES %@", ("^\\n*" + title + "$"))
            } else {
                return NSPredicate(format: "label == %@", title)
            }
        }()
        let matchingElementTitle = app.descendants(matching: .alert).element(matching: predicateTitle)
        let expectation = testCase.expectation(for: predicateTitle, evaluatedWith: matchingElementTitle, handler: nil)
        let result = XCTWaiter().wait(for: [expectation], timeout: Test.Timeout)
        if result != .completed {
            XCTAssertTrue(matchingElementTitle.exists, "Did not find alert with title: \(title)", file: file, line: line)
        }

        if let body = body {
            let predicateBody = NSPredicate(format: "label == %@", body)
            let matchingElementBody = app
                .descendants(matching: .alert)
                .element(matching: predicateTitle)
                .descendants(matching: .staticText)
                .element(matching: predicateBody)
            let expectation = testCase.expectation(for: predicateBody, evaluatedWith: matchingElementBody, handler: nil)
            let result = XCTWaiter().wait(for: [expectation], timeout: Test.Timeout)
            if result != .completed {
                XCTAssertTrue(matchingElementBody.exists, "Did not find alert with body: \(body)", file: file, line: line)
            }
        }
        return self
    }

    /// Checks alert doesn't appear with a title
    ///
    /// ```
    /// .confirmAlertIsNotDisplayed("title of alert")
    /// ```
    ///
    /// - Parameter title: title of alert
    @discardableResult
    public func confirmAlertIsNotDisplayed(_ title: String, in file: StaticString = #file, at line: UInt = #line) -> Self {
        guard let element = element(title, type: .alert) else { return self }
        XCTAssertFalse(element.exists, "Unexpectedly found alert with title: \(title)", file: file, line: line)
        return self
    }

    /// Taps alert button with title
    ///
    /// ```
    /// .tapAlertButton("button text")
    /// ```
    ///
    /// - Parameter title: text of button
    @discardableResult
    public func tapAlertButton(_ title: String, in file: StaticString = #file, at line: UInt = #line) -> Self {
        let button = app.alerts.buttons[title]
        guard button.exists else {
            XCTFail("Did not find alert button with title: \(title)", file: file, line: line)
            return self
        }
        button.tap()
        return self
    }

    /// Taps action sheet button
    ///
    /// ```
    /// .tapAlertActionButton("button text")
    /// ```
    ///
    /// - Parameter title: text of button
    @discardableResult
    public func tapAlertActionButton(_ title: String, in file: StaticString = #file, at line: UInt = #line) -> Self {
        let button = app.sheets.buttons[title]
        guard button.exists else {
            XCTFail("Did not find alert action button with title: \(title)", file: file, line: line)
            return self
        }
        button.firstMatch.tap()
        return self
    }

    // MARK: - Cells

    /// Checks the number of cells displayed on screen
    ///
    /// ```
    /// .confirmCellsAreDisplayed(count: 2)
    /// ```
    ///
    /// - Parameter count: The number of expected cells
    @discardableResult
    public func confirmCellsAreDisplayed(
        count: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        XCTAssertEqual(app.cells.count, count)
        return self
    }

    /// Checks the text contained within a cell
    ///
    /// ```
    /// .confirmCellContainsText(index: 0, text: "cell text")
    /// ```
    ///
    /// - Parameter index: Position of the cell to check
    /// - Parameter text: Text to be checked
    @discardableResult
    public func confirmCellContainsText(
        index: Int,
        text: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {

        let cell = app.cells.element(boundBy: index)
        XCTAssertTrue(
            cell.descendants(matching: .staticText)[text].exists,
            "Failed to find text: \(text) in cell: \(index)"
        )
        return self
    }

    /// Checks a cell is not displayed
    ///
    /// ```
    /// .confirmCellIsNotDisplayed("cell identifier")
    /// ```
    ///
    /// - Parameter identifier: Identifier of cell
    @discardableResult
    public func confirmCellIsNotDisplayed(
        _ identifier: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {

        let cell = app.cells[identifier]
        XCTAssertFalse(cell.exists, file: file, line: line)
        return self
    }

    // MARK: - Other Views

    /// Taps a view if it's on screen
    ///
    /// ```
    /// .tapViewWithIdentifier("view_accessibility_identifier")
    /// ```
    ///
    /// - Warning: onScreen defaults to false
    ///
    /// - Parameter identifier: Identifier of view
    /// - Parameter onScreen: Checks if view is currently displayed
    /// - Parameter waitForQuiescence: Wait for the app to become idle
    @discardableResult
    public func tapViewWithIdentifier(
        _ identifier: String,
        onScreen: Bool = false,
        waitForQuiescence: Bool = true,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {

        if !waitForQuiescence {
            disableWaitForIdle()
        }

        tapElementWithLabel(identifier, type: .other, onScreen: onScreen, in: file, at: line)

        if !waitForQuiescence {
            enableWaitForIdle()
        }
        return self
    }

    /// Checks to see if a given view is on screen
    ///
    /// ```
    /// .confirmViewIsDisplayed("view_accessibility_identifier")
    /// ```
    ///
    /// - Parameter identifier: Identifier of view
    @discardableResult
    public func confirmViewIsDisplayed(
        _ identifier: String,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {
        confirmElementIsDisplayed(identifier, type: .other, in: file, at: line)
    }

    /// Checks to see if a given view is not on screen
    ///
    /// ```
    /// .confirmViewIsNotDisplayed("view_accessibility_identifier")
    /// ```
    ///
    /// - Parameter identifier: Identifier of view
    @discardableResult
    public func confirmViewIsNotDisplayed(
        _ identifier: String,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {
        confirmElementIsNotDisplayed(identifier, type: .other, in: file, at: line)
    }

    /// Attempts to tap an element with a given label
    ///
    /// ```
    /// .tapElementWithLabel("view_accessibility_identifier", type: .switch)
    /// ```
    ///
    /// - Warning: onScreen defaults to false
    ///
    /// - Parameter text: String contained in element
    /// - Parameter type: Element type to check
    /// - Parameter onScreen: Checks if element is currently on screen
    @discardableResult
    public func tapElementWithLabel(
        _ text: String,
        type: XCUIElement.ElementType,
        onScreen: Bool = false,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {

        guard let element = element(text, type: type, onScreen: onScreen), element.isEnabled else {
            XCTFail("Element: \(text) is not enabled", file: file, line: line)
            return self
        }

        element.tap()
        return self
    }

    /// Checks to see if a given element is displayed
    ///
    /// ```
    /// .confirmElementIsDisplayed("view_accessibility_identifier", type: .switch)
    /// ```
    ///
    /// - Parameter text: String contained in element
    /// - Parameter type: Element type to check
    @discardableResult
    public func confirmElementIsDisplayed(
        _ title: String,
        type: XCUIElement.ElementType,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {
        guard let element = element(title, type: type) else {
            XCTFail("Element: \(title) was not displayed", file: file, line: line)
            return self
        }
        XCTAssertTrue(element.exists)
        XCTAssertTrue(element.isHittable)
        return self
    }

    /// Checks to see if a given element is not displayed
    ///
    /// ```
    /// .confirmElementIsNotDisplayed("view_accessibility_identifier", type: .switch)
    /// ```
    ///
    /// - Parameter text: String contained in element
    /// - Parameter type: Element type to check
    @discardableResult
    public func confirmElementIsNotDisplayed(
        _ title: String,
        type: XCUIElement.ElementType,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {
        guard let element = element(title, type: type) else { return self }
        XCTAssertFalse(element.exists)
        XCTAssertFalse(element.isHittable)
        return self
    }

    // MARK: - Tracking & Audit

    /// Taps link with text
    ///
    /// ```
    /// .tapLinkWithLabel("link text")
    /// ```
    ///
    /// - Warning: onScreen defaults to false
    ///
    /// - Parameter text: String contained in link
    /// - Parameter onScreen: Checks if the link is currently on screen
    @discardableResult
    public func tapLinkWithLabel(
        _ text: String,
        onScreen: Bool = false,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {
        let predicate = NSPredicate(format: "label == %@", text)
        let matchingElements = app.descendants(matching: .link).matching(predicate).allElementsBoundByIndex
        let links = matchingElements.filter { (element) -> Bool in
            elementExistsAndIsVisible(element, onScreen: onScreen)
        }

        guard let firstLink = links.first else {
            XCTFail("Didn't find link: \(text)", file: file, line: line)
            return self
        }

        guard firstLink.isEnabled else {
            XCTFail("Link: \(text) is not enabled", file: file, line: line)
            return self
        }

        firstLink.tap()
        return self
    }

    /// Waits for specific element before continuing
    ///
    /// ```
    /// .awaitElement(type: .button, "link text")
    /// ```
    ///
    /// - Parameter type: Element type to wait for
    /// - Parameter text: Text contained within element
    @discardableResult
    public func awaitElement(
        type: XCUIElement.ElementType,
        text: String,
        file: String = #file,
        line: Int = #line
    ) -> Self {
        testCase.waitUntilOrAssert("Element exists", in: file, at: line) { () -> String? in

            let predicate: NSPredicate = {
                if type == .navigationBar {
                    return NSPredicate(format: "identifier == %@", text)
                } else {
                    return NSPredicate(format: "label == %@", text)
                }
            }()
            let matchingElements = app.descendants(matching: type).matching(predicate).allElementsBoundByIndex
            let elements = matchingElements.filter { (element) -> Bool in
                elementExistsAndIsVisible(element, onScreen: true)
            }
            if elements.isEmpty {
                return("Didn't find element with text: \(text)")
            } else {
                return nil
            }
        }
        return self
    }

    /// Taps button with specific Id
    ///
    /// ```
    /// .tapButtonWithId("button_id")
    /// ```
    ///
    /// - Parameter id: Accessibility id of button
    @discardableResult
    public func tapButtonWithId(
        _ id: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        let buttonsQuery = self.app.buttons.matching(identifier: id)
        let button = buttonsQuery.element(boundBy: 0)
        XCTAssertTrue(button.exists, "Button with ID: \(id) doesn't exist", file: file, line: line)
        button.tap()
        return self
    }

    /// Checks to see if GA track view has been called
    ///
    /// ```
    /// .confirmViewIsTracked("view_name")
    /// ```
    ///
    /// - Warning: This will only check if a GA screen view has been logged
    ///
    /// - Parameter viewName: Name of view to check
    @discardableResult
    public func confirmViewIsTracked(
        viewName: String,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {
        let lastEvent = testCase.getRecordedAnalyticsServiceEvents().filter { $0.viewName != nil }.last
        XCTAssertEqual(lastEvent?.viewName, viewName, "view \(viewName) not tracked", file: file, line: line)
        return self
    }

    /// Checks to see if firebase view has been logged
    ///
    /// ```
    /// .confirmViewIsLoggedInFirebase("view_name")
    /// ```
    ///
    /// - Warning: This will only check if a Firebase screen view has been logged
    ///
    /// - Parameter viewName: Name of view to check
    @discardableResult
    public func confirmViewIsLoggedInFirebase(
        viewName: String,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {
        guard let lastEvent = testCase.getRecordedFirebaseEvents().filter({ $0.parameters == ["event_type": "screen"] }).last else {
            XCTFail("No last screen event found. Was expecting event for '\(viewName)'", file: file, line: line)
            return self
        }
        XCTAssertEqual(
            viewName,
            lastEvent.event,
            file: file,
            line: line
        )
        return self
    }

    /// Checks to if a event has not been tracked
    ///
    /// ```
    /// .confirmEventIsNotTracked(category: "event_category", action: "event_action", label: "event_label")
    /// ```
    ///
    /// - Warning: This will only check if a GA event has not been logged
    /// - Warning: Value defaults to nil
    ///
    /// - Parameter category: Event category string
    /// - Parameter action: Event action string
    /// - Parameter label: Event label string
    /// - Parameter value: Event value NSNumber
    /// - Parameter value: Event value NSNumber
    @discardableResult
    public func confirmEventIsNotTracked(
        category: String,
        action: String,
        label: String,
        value: NSNumber?=nil,
        in file: String = #file,
        at line: Int = #line) -> Self {

        testCase.waitUntilOrAssert("GA event is tracked", in: file, at: line) { () -> String? in
            let event = testCase.getRecordedAnalyticsServiceEvents().first { lastEvent -> Bool in
                lastEvent.eventCategory != category
                    && lastEvent.eventAction != action
                    && lastEvent.eventLabel != label
                    && lastEvent.eventValue != value
            }
            if event != nil {
                return "Found GA event: \(category)/\(action)/\(label)"
            } else {
                return nil
            }
        }
        return self
    }

    /// Checks to if a event was the last one to be tracked
    ///
    /// ```
    /// .confirmEventIsTracked(category: "event_category", action: "event_action", label: "event_label")
    /// ```
    ///
    /// - Warning: This will only check if a GA event has been logged
    /// - Warning: Value defaults to nil
    ///
    /// - Parameter category: Event category string
    /// - Parameter action: Event action string
    /// - Parameter label: Event label string
    /// - Parameter value: Event value NSNumber
    @discardableResult
    public func confirmEventIsTracked(
        category: String,
        action: String,
        label: String,
        value: NSNumber? = nil,
        in file: String = #file,
        at line: Int = #line
    ) -> Self {

        testCase.waitUntilOrAssert("GA event is tracked", in: file, at: line) { () -> String? in
            let event = testCase.getRecordedAnalyticsServiceEvents().first { lastEvent -> Bool in
                lastEvent.eventCategory == category
                    && lastEvent.eventAction == action
                    && lastEvent.eventLabel == label
                    && lastEvent.eventValue == value
            }
            if event == nil {
                return "Didn't track GA event: \(category)/\(action)/\(label)"
            } else {
                return nil
            }
        }
        return self
    }

    /// Checks to if a event was the last one to be audited
    ///
    /// ```
    /// .confirmEventIsAudited(eventType: "event_type", eventPath: "event_path", eventDetail: ["event" : "detail"]])
    /// ```
    ///
    /// - Warning: This will only check if a audit event has been logged
    /// - Warning: eventPath defaults to nil
    /// - Warning: eventDetail defaults to nil
    ///
    /// - Parameter eventType: Audit type for event
    /// - Parameter eventPath: Audit path for event
    /// - Parameter eventDetail: Audit details for event
    @discardableResult
    public func confirmEventIsAudited(
        eventType: String,
        eventPath: String? = nil,
        eventDetail: [String: String]? = nil,
        in file: String = #file,
        at line: Int = #line
    ) -> Self {

        testCase.waitUntilOrAssert("Event is audited", in: file, at: line) { () -> String? in
            guard let lastEvent = testCase.getRecordedAuditServiceEvents().last else {
                return "No last audit event found. Was expecting type '\(eventType)' with path: " + (eventPath ?? "N/A")
            }
            if eventType != lastEvent.eventType {
                return "Last audit event type does not match \(eventType)"
            } else {
                if eventPath == nil && eventDetail == nil {
                    return nil
                }
            }
            if let eventPath = eventPath, let eventDetail = eventDetail {
                if lastEvent.eventPath == eventPath && eventDetail == lastEvent.eventDetail {
                    return nil
                } else {
                    return "Last audit event path and detail do not match \(eventPath) & \(eventDetail)"
                }
            } else if let eventPath = eventPath {
                if lastEvent.eventPath == eventPath {
                    return nil
                } else {
                    return "Last audit event path does not match \(eventPath)"
                }
            } else if let eventDetail = eventDetail {
                if eventDetail == lastEvent.eventDetail {
                    return nil
                } else {
                    return "Last audit event detail does not match \(eventDetail)"
                }
            }
            return "Last audit event not matched"
        }
        return self
    }

    /// Checks to if an audit event has fired at all
    ///
    /// ```
    /// .confirmAuditedEventsContain(eventType: "event_type", eventPath: "event_path", eventDetail: ["event" : "detail"]])
    /// ```
    ///
    /// - Warning: This will only check if a audit event has been logged
    /// - Warning: eventPath defaults to nil
    /// - Warning: eventDetail defaults to nil
    ///
    /// - Parameter eventType: Audit type for event
    /// - Parameter eventPath: Audit path for event
    /// - Parameter eventDetail: Audit details for event
    @discardableResult
    public func confirmAuditedEventsContain(
        eventType: String,
        eventPath: String? = nil,
        eventDetail: [String: String]? = nil,
        in file: StaticString = #file,
        at line: UInt = #line
    ) -> Self {

        let matchingEvents = testCase.getRecordedAuditServiceEvents().filter {
            let typeMatches = $0.eventType == eventType
            let pathMatches: Bool = {
                if let eventPath = eventPath {
                    return $0.eventPath == eventPath
                } else {
                    return true
                }
            }($0)
            let detailMatches: Bool = {
                if let eventDetail = eventDetail {
                    return $0.eventDetail == eventDetail
                } else {
                    return true
                }
            }($0)

            return typeMatches && pathMatches && detailMatches
        }

        if matchingEvents.isEmpty {
            XCTFail("No matching events found. Was expecting type '\(eventType)' with path: " + (eventPath ?? "N/A"), file: file, line: line)
        }
        return self
    }

    /// Checks to if an error has been audited
    ///
    /// ```
    /// .confirmErrorIsAudited(eventType: "event_type", errorCode: "404")
    /// ```
    ///
    /// - Parameter eventType: Audit type for event
    /// - Parameter errorCode: Error code attached to event
    @discardableResult
    public func confirmErrorIsAudited(eventType: String, errorCode: String, file: StaticString = #file, line: UInt = #line) -> Self {
        let lastEvent = testCase.getRecordedAuditServiceEvents().last

        XCTAssertEqual(lastEvent?.eventType, eventType, file: file, line: line)
        XCTAssertEqual(lastEvent?.eventDetail?["errorCode"], errorCode, file: file, line: line)
        XCTAssertNotNil(lastEvent?.eventDetail?["errorBody"], file: file, line: line)
        return self
    }

    /// Checks if Firebases user properties have been updated
    ///
    /// ```
    /// .confirmFirebaseUserPropertyIsLogged(name: "property name", value: "property value")
    /// ```
    ///
    /// - Parameter name: Firebase property name
    /// - Parameter value: Expected firebase property value
    @discardableResult
    public func confirmFirebaseUserPropertyIsLogged(name: String, value: String, file: StaticString = #file, line: UInt = #line) -> Self {
        let properties = testCase.getFirebaseUserProperties()
        XCTAssertEqual(properties[name], value, file: file, line: line)

        return self
    }

    /// Checks the last firebase event is expected
    ///
    /// ```
    /// .confirmLastFirebaseEvent(event: "event name", parameters: ["param name": "param value"])
    /// ```
    ///
    /// - Warning: Parameters is nil by default
    ///
    /// - Parameter event: Firebase event name
    /// - Parameter parameter: String dictionary of parameters and values
    @discardableResult
    public func confirmLastFirebaseEvent(
        event: String,
        parameters: [String: String]? = nil,
        file: String = #file,
        line: Int = #line
    ) -> Self {

        testCase.waitUntilOrAssert("Firebase event is logged", in: file, at: line) { () -> String? in
            guard let lastEvent = testCase.getRecordedFirebaseEvents().last else {
                return "No last firebase event found. Was expecting '\(event)'"
            }
            if event != lastEvent.event {
                return "Last firebase event '\(lastEvent.event)' does not match expected '\(event)'"
            }
            if let parameters = parameters {
                if parameters == lastEvent.parameters {
                    return nil
                } else {
                    return "Last firebase event parameters \(String(describing: lastEvent.parameters)) do not match expected \(String(describing: parameters))" //swiftlint:disable:this line_length
                }
            } else {
                if lastEvent.parameters == nil {
                    return nil
                }
            }
            return "Last firebase event not matched"
        }
        return self
    }

    /// Checks all firebase events to see if it contains one
    ///
    /// ```
    /// .confirmFirebaseEventsContain(event: "event name", parameters: ["param name": "param value"])
    /// ```
    ///
    /// - Warning: Parameters is nil by default
    ///
    /// - Parameter event: Firebase event name
    /// - Parameter parameter: String dictionary of parameters and values
    @discardableResult
    public func confirmFirebaseEventsContain(
        event: String,
        parameters: [String: String]? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {

        let matchingEvents = testCase.getRecordedFirebaseEvents().filter {
            event == $0.event && parameters == $0.parameters
        }

        if matchingEvents.isEmpty {
            XCTFail("No matching events found. Was expecting event '\(event)' with parameters: \(String(describing: parameters))", file: file, line: line) //swiftlint:disable:this line_length
        }
        return self
    }

    // MARK: - URLs

    /// Checks the last opened URL to see if it matches a regex expression
    ///
    /// ```
    /// .confirmUrlIsOpened(regex: "[aA]")
    /// ```
    ///
    /// - Parameter regex: A regex expression of urls to check for
    @discardableResult
    public func confirmUrlIsOpened(
        regex: String,
        in file: String = #file,
        at line: Int = #line
    ) -> Self {

        testCase.waitUntilOrAssert("URL is opened", in: file, at: line) { () -> String? in
            guard let lastUrl = testCase.getLastOpenedURL() else {
                return "Unable to obtain last opened URL"
            }
            let regexTest = NSPredicate(format: "SELF MATCHES %@", regex)
            if regexTest.evaluate(with: lastUrl) {
                return nil
            } else {
                return "LastUrl: \"\(lastUrl)\" does not match \"\(regex)\""
            }
        }
        return self
    }

    /// Checks the last opened URL to see if it matches a absolute url
    ///
    /// ```
    /// .confirmUrlIsOpened(absolute: "http://www.google.com")
    /// ```
    ///
    /// - Parameter absolute: An absolute url to check
    @discardableResult
    public func confirmUrlIsOpened(
        absolute: String,
        in file: String = #file,
        at line: Int = #line
    ) -> Self {

        testCase.waitUntilOrAssert("URL is opened", in: file, at: line) { () -> String? in
            guard let lastUrl = testCase.getLastOpenedURL() else {
                return "Unable to obtain last opened URL"
            }
            if absolute == lastUrl {
                return nil
            } else {
                return "LastUrl: \"\(lastUrl)\" does not equal \"\(absolute)\""
            }
        }
        return self
    }

    // MARK: - Rating

    /// Checks to see if the app store rating service has been called
    ///
    /// ```
    /// .confirmAppStoreRatingIsRequested()
    /// ```
    ///
    @discardableResult
    public func confirmAppStoreRatingIsRequested(in file: String = #file, at line: Int = #line) -> Self {
        testCase.waitUntilOrAssert("Rating is requested", in: file, at: line) { () -> String? in
            if testCase.getRateCalled() {
                return nil
            } else {
                return "Expected rateCalled to be true"
            }
        }
        return self
    }

    /// Checks to see if the app store rating service has not been called
    ///
    /// ```
    /// .confirmAppStoreRatingIsNotRequested()
    /// ```
    ///
    @discardableResult
    public func confirmAppStoreRatingIsNotRequested(in file: String = #file, at line: Int = #line) -> Self {
        testCase.waitUntilOrAssert("Rating is requested", in: file, at: line) { () -> String? in
            if testCase.getRateCalled() {
                return "Expected rateCalled to be false"
            } else {
                return nil
            }
        }
        return self
    }

    // MARK: - Misc

    /// Checks to see if the devices clip board matches a string
    ///
    /// ```
    /// .confirmClipboardContainsText("text to check")
    /// ```
    ///
    /// - Warning: allowPartialMatch defaults to nil
    ///
    /// - Parameter text: Text to check for
    /// - Parameter allowPartialMatch: Should the text match exactly
    @discardableResult
    public func confirmClipboardContainsText(
        _ text: String,
        allowPartialMatch: Bool = false,
        file: String = #file,
        line: Int = #line
    ) -> Self {

        waitUntilOrAssert("Text is copied to clipboard", in: file, at: line) { () -> String? in
            let clipboardText = UIPasteboard.general.string
             if allowPartialMatch {
                if clipboardText!.contains(find: text) {
                    return nil
                } else {
                    return "Text \(text) does not match clipboard \(String(describing: clipboardText))"
                }
             } else {
                if clipboardText != text {
                    return "Text \(text) does not match clipboard \(String(describing: clipboardText))"
                } else {
                    return nil
                }
            }
        }
        return self
    }

    // MARK: - Helpers

    /// Defines a block to complete within a timeout
    ///
    /// ```
    /// .waitUntilOrAssert("description of block", timeout: 30) { assertionBlock }
    /// ```
    ///
    /// - Warning: Timeout defaults to global test timeout if not defined
    ///
    /// - Parameter description: A general description of the assertion block
    /// - Parameter timeout: How long the block has to run before failing
    /// - Parameter assertionBlock: A block of commands to be run
    public func waitUntilOrAssert(
        _ description: String,
        timeout: TimeInterval = Test.Timeout,
        in file: String,
        at line: Int,
        _ assertionBlock: Test.AssertionBlock
    ) {
        testCase.waitUntilOrAssert(description, timeout: timeout, in: file, at: line, assertionBlock)
    }

    /// Captures a screenshot of the current screen to be added to the HTML and screenshot diff
    ///
    /// ```
    /// .capture(screen: .{{screen_name}})
    /// ```
    ///
    /// - Warning: Screens captured with this should be setup in the HTML generator and added to the Screen capture list
    /// - Warning: Screens captured should also have a baseline added to the mobile-screenshot-diff repo for comparison
    ///
    /// - Parameter screen: Enum case for screen to be captured
    @discardableResult
    public func capture(screen: Capture.Screen) -> Self {
        testCase.capture(screen: screen)
        return self
    }
}

// MARK: - Private
private extension Page {

    @discardableResult
    func disableWaitForIdle() -> Self {
        testCase.disableWaitForIdle()
        return self
    }

    @discardableResult
    func enableWaitForIdle() -> Self {
        testCase.enableWaitForIdle()
        return self
    }

    func split(urlString: String) -> (host: String?, queryItems: [URLQueryItem]?) {
        guard let components = URLComponents(string: urlString) else { return (nil, []) }
        return (components.host, components.queryItems)
    }

    @discardableResult
    func typeIntoElement(
        element: XCUIElement,
        text: String,
        clearFirst: Bool = false,
        file: StaticString = #file,
        line: UInt = #line) -> Self {
        XCTAssertTrue(element.exists, "Could not find text field", file: file, line: line)

        let hittablePredicate = NSPredicate(format: "hittable == true")
        let expectation = testCase.expectation(for: hittablePredicate, evaluatedWith: element, handler: nil)
        let result = XCTWaiter().wait(for: [expectation], timeout: Test.Timeout)
        if result != .completed {
            XCTFail("Element is not hittable", file: file, line: line)
        }
        element.tap()
        if clearFirst && app.buttons["Clear"].exists {
            app.buttons["Clear"].tap()
        }

        hideContinuousPathIntroductionViewIfVisible(file: file, line: line)

        element.typeText(text)

        return self
    }

    @discardableResult
    func hideContinuousPathIntroductionViewIfVisible(file: StaticString = #file, line: UInt = #line) -> Self {
        let overlay = app.otherElements["UIContinuousPathIntroductionView"]
        if elementExistsAndIsVisible(overlay) {
            overlay.buttons.element(boundBy: 0).tap()

            let visiblePredicate = NSPredicate(format: "exists == false")
            let expectation = testCase.expectation(for: visiblePredicate, evaluatedWith: overlay, handler: nil)
            let result = XCTWaiter().wait(for: [expectation], timeout: Test.Timeout)
            if result != .completed {
                XCTFail("Overlay has not been cleared", file: file, line: line)
            }
        }

        return self
    }

    func element(_ title: String, type: XCUIElement.ElementType, onScreen: Bool = false) -> XCUIElement? {
        let predicate = NSPredicate(format: "label == %@ || identifier == %@", title, title)
        let matchingElements = app.descendants(matching: type).matching(predicate).allElementsBoundByIndex
        guard let element = matchingElements.first(where: { elementExistsAndIsVisible($0, onScreen: onScreen) }) else {
            return nil
        }
        return element
    }

    func elementPartialMatch(_ title: String, type: XCUIElement.ElementType, onScreen: Bool = false) -> XCUIElement? {
        let predicate = NSPredicate(format: "label CONTAINS[cd] %@ || identifier == %@", title, title)
        let matchingElements = app.descendants(matching: type).matching(predicate).allElementsBoundByIndex
        guard let element = matchingElements.first(where: { elementExistsAndIsVisible($0, onScreen: onScreen) }) else {
            return nil
        }
        return element
    }

    func staticTextIsVisible(_ text: String, onScreen: Bool = false) -> Bool {
        let predicate = NSPredicate(format: "label == %@", text)
        let matchingElement = app.descendants(matching: .staticText).element(matching: predicate)
        return elementExistsAndIsVisible(matchingElement, onScreen: onScreen)
    }

    func textViewIsVisible(_ text: String, onScreen: Bool = false) -> Bool {
        let predicate = NSPredicate(format: "value == %@", text)
        let matchingElement = app.descendants(matching: .staticText).element(matching: predicate)
        return elementExistsAndIsVisible(matchingElement, onScreen: onScreen)
    }

    func staticTextIsVisibleMultipleTimes(_ text: String, count: Int, onScreen: Bool = false) -> Bool {
        let predicate = NSPredicate(format: "label == %@", text)
        let matchingElements = app.descendants(matching: .staticText).matching(predicate).allElementsBoundByIndex
        return elementExistsAndIsVisibleMultipleTimes(matchingElements, count: count, onScreen: onScreen)
    }

    func textViewIsVisibleMultipleTimes(_ text: String, count: Int, onScreen: Bool = false) -> Bool {
        let predicate = NSPredicate(format: "value == %@", text)
        let matchingElements = app.descendants(matching: .textView).matching(predicate).allElementsBoundByIndex
        return elementExistsAndIsVisibleMultipleTimes(matchingElements, count: count, onScreen: onScreen)
    }

    func partialStaticTextExists(_ partialText: String) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS[cd] %@", partialText)
        let matchingElement = app.descendants(matching: .staticText).element(matching: predicate)
        return elementExistsAndIsVisible(matchingElement)
    }

    func partialTextViewExists(_ text: String) -> Bool {
        let predicate = NSPredicate(format: "value CONTAINS[cd] %@", text)
        let matchingElement = app.descendants(matching: .textView).element(matching: predicate)
        return elementExistsAndIsVisible(matchingElement)
    }

    func partialStaticTextIsVisibleMultipleTimes(_ partialText: String, count: Int) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS[cd] %@", partialText)
        let matchingElements = app.descendants(matching: .staticText).matching(predicate).allElementsBoundByIndex
        return elementExistsAndIsVisibleMultipleTimes(matchingElements, count: count)
    }

    func partialTextViewIsVisibleMultipleTimes(_ partialText: String, count: Int) -> Bool {
        let predicate = NSPredicate(format: "value CONTAINS[cd] %@", partialText)
        let matchingElements = app.descendants(matching: .textView).matching(predicate).allElementsBoundByIndex
        return elementExistsAndIsVisibleMultipleTimes(matchingElements, count: count)
    }

    func elementExistsAndIsVisible(_ element: XCUIElement, onScreen: Bool = false) -> Bool {
        element.exists &&
            (element.frame.size.width > 0 && element.frame.size.height > 0) &&
            (onScreen ? element.isHittable : true)
    }

    func elementExistsAndIsVisibleMultipleTimes(_ elements: [XCUIElement], count: Int, onScreen: Bool = false) -> Bool {
        let visibleMatchingElements = elements.filter {
            $0.exists && $0.frame.size.width > 0 && $0.frame.size.height > 0 && (onScreen ? $0.isHittable : true)
        }
        // swiftlint:disable:next empty_count
        return count > 0 ? visibleMatchingElements.count == count : visibleMatchingElements.count > 0
    }
}

// swiftlint:enable type_body_length file_length
