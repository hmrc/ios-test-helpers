//
// Adapted from: https://gist.github.com/ryanmeisters/f4e961731db289f489e1a08183e334d9
//

#if DEBUG

import XCTest
import Foundation
import SBTUITestTunnelClient

    extension XCUIApplication {
        private struct Constants {
            // Half way accross the screen and 40% from top
            static let topOffset = CGVector(dx: 0.5, dy: 0.4)

            // Half way accross the screen and 80% from top
            static let bottomOffset = CGVector(dx: 0.5, dy: 0.8)
        }

        var screenTopCoordinate: XCUICoordinate {
            windows.firstMatch.coordinate(withNormalizedOffset: Constants.topOffset)
        }

        var screenBottomCoordinate: XCUICoordinate {
            windows.firstMatch.coordinate(withNormalizedOffset: Constants.bottomOffset)
        }

        func scrollDownTo(element: XCUIElement, maxScrolls: Int = 5) {
            for _ in 0..<maxScrolls {
                if element.exists && element.isHittable { break }
                scrollDown()
            }
        }

        func scrollUpTo(element: XCUIElement, maxScrolls: Int = 5) {
            for _ in 0..<maxScrolls {
                if element.exists && element.isHittable { break }
                scrollUp()
            }
        }

        func scrollDown() {
            screenBottomCoordinate.press(forDuration: 0.1, thenDragTo: screenTopCoordinate)
        }

        func scrollUp() {
            screenTopCoordinate.press(forDuration: 0.1, thenDragTo: screenBottomCoordinate)
        }
    }

    extension XCUIElement {
        func scrollToTop() {
            let topCoordinate = XCUIApplication().screenTopCoordinate
            let elementCoordinate = coordinate(withNormalizedOffset: .zero)

            let delta = topCoordinate.screenPoint.x - elementCoordinate.screenPoint.x
            let deltaVector = CGVector(dx: delta, dy: 0.0)

            elementCoordinate.withOffset(deltaVector).press(forDuration: 0.1, thenDragTo: topCoordinate)
        }
    }

#endif
