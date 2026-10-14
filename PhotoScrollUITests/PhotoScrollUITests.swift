//
//  PhotoScrollUITests.swift
//  PhotoScrollUITests
//
//  Created by Капитонов Константин Евгеньевич on 13.10.2026.
//

import XCTest

final class PhotoScrollUITests: XCTestCase {
    private let app = XCUIApplication()
    private let email = ""
    private let password = ""

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAuth() throws {
        app.launch()

        let authenticateButton = app.buttons["authenticate_button"]
        XCTAssertTrue(
            authenticateButton.waitForExistence(timeout: 10),
            "The authentication screen did not appear"
        )
        authenticateButton.tap()

        let webView = app.webViews["auth_web_view"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "The authentication page did not open")

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5), "The email field did not appear")
        loginTextField.tap()
        loginTextField.typeText(email)

        dismissKeyboardIfPresent()

        let passwordField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5), "The password field did not appear")
        passwordField.tap()
        passwordField.typeText(password)

        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "The Login button did not appear")
        loginButton.tap()

        let cell = app.tables.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "The feed did not appear")
    }

    @MainActor
    func testFeed() throws {
        app.launch()

        // Подождать, пока открывается и загружается экран ленты
        let table = app.tables["images_list"]
        XCTAssertTrue(table.waitForExistence(timeout: 10), "Лента не появилась")
        let firstCell = table.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Лента не прогрузилась")

        // Сделать жест «смахивания» вверх по экрану для его скролла
        table.swipeUp()

        // Поставить лайк в ячейке верхней картинки
        let cellToLike = table.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5), "фото для лайка не прогрузилось")
        let likeButton = cellToLike.children(matching: .button).element
        likeButton.tap()

        sleep(2)
        XCTAssertTrue(likeButton.identifier == "unlike_button", "Лайк не поставлен")

        // Отменить лайк в ячейке верхней картинки
        likeButton.tap()
        sleep(2)
        XCTAssertTrue(likeButton.identifier == "like_button", "Лайк не отменен")

//        // Нажать на верхнюю ячейку
//        cellToLike.tap()
//
//        // Подождать, пока картинка открывается на весь экран
//        let image = app.scrollViews.images.element(boundBy: 0)
//        XCTAssertTrue(image.waitForExistence(timeout: 10), "Картинка не открылась")
//
//        // Увеличить картинку
//        image.pinch(withScale: 3, velocity: 1)
//
//        // Уменьшить картинку
//        image.pinch(withScale: 0.5, velocity: -1)
//
//        // Вернуться на экран ленты
//        let backButton = app.buttons["single_image_back_button"]
//        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка назад не найдена")
//        backButton.tap()
//        XCTAssertTrue(image.waitForNonExistence(timeout: 5), "Картинка не закрылась")
    }

    @MainActor
    func testProfile() throws {
        app.launch()

        // Подождать, пока открывается и загружается экран ленты
        let table = app.tables["images_list"]
        XCTAssertTrue(table.waitForExistence(timeout: 10), "Лента не появилась")
        // Перейти на экран профиля
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5), "Вкладка профиля не найдена")
        profileTab.tap()

        // Проверить, что на нём отображаются ваши персональные данные
        let name = app.staticTexts["profile_name"]
        let username = app.staticTexts["profile_username"]
        let description = app.staticTexts["profile_description"]
        XCTAssertTrue(name.waitForExistence(timeout: 5), "Имя не отображается")
        XCTAssertTrue(username.exists, "Логин не отображается")
        XCTAssertTrue(description.exists, "Описание профиля не отображается")

        // Нажать кнопку логаута
        let logoutButton = app.buttons["profile_logout_button"]
        XCTAssertTrue(logoutButton.exists, "Кнопка выхода не найдена")
        logoutButton.tap()
        let confirmButton = app.alerts.buttons["Да"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5), "Диалог выхода не появился")
        confirmButton.tap()

        // Проверить, что открылся экран авторизации
        let authenticateButton = app.buttons["authenticate_button"]
        XCTAssertTrue(
            authenticateButton.waitForExistence(timeout: 5),
            "Экран авторизации не открылся"
        )
    }
    
    private func dismissKeyboardIfPresent() {
        if app.keyboards.element(boundBy: 0).exists {
            if UIDevice.current.userInterfaceIdiom == .pad {
                app.keyboards.buttons["Hide keyboard"].tap()
            } else {
                app.toolbars.buttons["Done"].tap()
            }
        }
    }
}
