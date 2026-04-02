import XCTest

final class MeowtropolisUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-uiTestSkipSplash", "-uiTestSkipOnboarding"]
        app.launch()

        XCTAssertTrue(app.buttons["authLandingLoginButton"].waitForExistence(timeout: 5))
    }
}
