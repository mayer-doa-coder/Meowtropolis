import XCTest

final class MeowtropolisUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsLoginScreen() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-uiTestSkipSplash", "-uiTestSkipOnboarding"]
        app.launch()

        let loginButton = app.buttons["authLandingLoginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Log In button should appear on auth landing screen.")

        loginButton.tap()

        let loginTitle = app.staticTexts["Log In"]
        XCTAssertTrue(loginTitle.waitForExistence(timeout: 3), "Login screen title should appear after tapping Log In.")
    }

    @MainActor
    func testPerformLoginNavigatesToDashboard() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-uiTestSkipSplash", "-uiTestSkipOnboarding", "-uiTestMockLoginSuccess"]
        app.launch()

        let loginButton = app.buttons["authLandingLoginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Auth landing should show Log In button.")
        loginButton.tap()

        let emailField = app.textFields["loginEmailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 3), "Email field should exist on login screen.")
        emailField.tap()
        emailField.typeText("uitest@meowtropolis.app")

        let passwordField = app.secureTextFields["loginPasswordField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 3), "Password field should exist on login screen.")
        passwordField.tap()
        passwordField.typeText("Meow123!")

        let submitButton = app.buttons["loginSubmitButton"]
        XCTAssertTrue(submitButton.exists, "Login submit button should exist.")
        submitButton.tap()

        let dashboard = app.otherElements["dashboardTabView"]
        XCTAssertTrue(dashboard.waitForExistence(timeout: 5), "Dashboard should appear after successful login.")
    }
}
