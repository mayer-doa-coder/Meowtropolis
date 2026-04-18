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

    @MainActor
    func testOpenMapTabShowsMapScreen() throws {
        let app = launchLoggedInApp()

        openMapTab(app)

        let mapScreen = app.otherElements["mapScreen"]
        XCTAssertTrue(mapScreen.waitForExistence(timeout: 5), "Map screen should appear after tapping Map tab.")
    }

    @MainActor
    func testMapSwitchCategoriesUpdatesSelectionState() throws {
        let app = launchLoggedInApp(mapScenario: "loading")

        openMapTab(app)

        let vetChip = app.buttons["categoryChip_vet"]
        let groomingChip = app.buttons["categoryChip_grooming"]
        XCTAssertTrue(vetChip.waitForExistence(timeout: 5), "Vet category chip should exist.")
        XCTAssertTrue(groomingChip.exists, "Grooming category chip should exist.")

        let selectedCategoryValue = app.staticTexts["selectedCategoryValue"]
        XCTAssertTrue(selectedCategoryValue.exists, "Selected category marker should exist.")

        vetChip.tap()
        XCTAssertEqual(selectedCategoryValue.label, "vet")

        groomingChip.tap()
        XCTAssertEqual(selectedCategoryValue.label, "grooming")

        let loadingIndicator = app.otherElements["loadingIndicator"]
        XCTAssertTrue(loadingIndicator.exists, "Loading indicator should remain visible in loading scenario.")
    }

    @MainActor
    func testMapNoResultsStateShowsMessage() throws {
        let app = launchLoggedInApp(mapScenario: "empty")

        openMapTab(app)

        let noResults = app.staticTexts["noResultsMessage"]
        XCTAssertTrue(noResults.waitForExistence(timeout: 5), "No-results message should appear for empty state.")
    }

    @MainActor
    func testMapErrorStateShowsRetryAndRetryActionTriggers() throws {
        let app = launchLoggedInApp(mapScenario: "error")

        openMapTab(app)

        let errorMessage = app.staticTexts["errorMessage"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 5), "Error message should be visible in error state.")

        let retryButton = app.buttons["retryButton"]
        XCTAssertTrue(retryButton.exists, "Retry button should be visible in error state.")

        let retryTapCounter = app.staticTexts["retryTapCountValue"]
        XCTAssertTrue(retryTapCounter.exists, "Retry action counter marker should exist for UI test scenario.")

        XCTAssertEqual(retryTapCounter.label, "retryCount:0")
        retryButton.tap()
        XCTAssertEqual(retryTapCounter.label, "retryCount:1")
    }

    @MainActor
    private func launchLoggedInApp(mapScenario: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-uiTestSkipSplash", "-uiTestSkipOnboarding", "-uiTestMockLoginSuccess"]
        if let mapScenario {
            app.launchEnvironment["UI_TEST_MAP_SCENARIO"] = mapScenario
        }
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

        return app
    }

    @MainActor
    private func openMapTab(_ app: XCUIApplication) {
        let mapTabButton = app.tabBars.buttons["Map"]
        XCTAssertTrue(mapTabButton.waitForExistence(timeout: 5), "Map tab should exist after login.")
        mapTabButton.tap()
    }
}
