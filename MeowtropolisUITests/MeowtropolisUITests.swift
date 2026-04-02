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

    @MainActor
    func testMarketplaceAddToCartFlow() throws {
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

        let shopTab = app.tabBars.buttons["Shop"]
        XCTAssertTrue(shopTab.waitForExistence(timeout: 5), "Shop tab should exist after login.")
        shopTab.tap()

        let productRowPredicate = NSPredicate(format: "identifier BEGINSWITH %@", "marketplaceProductRow_")
        let firstProduct = app.buttons.matching(productRowPredicate).firstMatch
        XCTAssertTrue(firstProduct.waitForExistence(timeout: 8), "At least one product row should exist in marketplace.")
        firstProduct.tap()

        let addToCartButton = app.buttons["productDetailAddToCartButton"]
        XCTAssertTrue(addToCartButton.waitForExistence(timeout: 5), "Add to Cart button should exist on product detail.")
        addToCartButton.tap()

        let successMessage = app.staticTexts["productDetailAddToCartSuccessMessage"]
        XCTAssertTrue(successMessage.waitForExistence(timeout: 3), "Success message should appear after adding to cart.")

        let cartButton = app.buttons["productDetailCartButton"]
        XCTAssertTrue(cartButton.exists, "Cart shortcut should exist on product detail.")
        cartButton.tap()

        let cartView = app.otherElements["cartView"]
        XCTAssertTrue(cartView.waitForExistence(timeout: 5), "Cart screen should open from product detail.")
    }
}
