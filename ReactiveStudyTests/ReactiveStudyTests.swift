//
//  ReactiveStudyTests.swift
//  ReactiveStudyTests
//
//  Created by Paker on 08/12/20.
//

import XCTest
import ReactiveSwift
@testable import ReactiveStudy

class ReactiveStudyTests: XCTestCase {

    let viewModel = LoginViewModel(loginService: MockLoginService())

    let (loginSignal, loginObserver) = Signal<String, Never>.pipe()
    let (passwordSignal, passwordObserver) = Signal<String, Never>.pipe()
    let (triggerSignal, triggerObserver) = Signal<Void, Never>.pipe()

    override func setUp() {
        viewModel.setUp(loginChanged: loginSignal, passwordChanged: passwordSignal, authTrigger: triggerSignal)
    }

    func test_login_and_password_shouldNotAcceptSpaces() throws {

        loginObserver.send(value: " a ")
        passwordObserver.send(value: " b ")

        XCTAssertEqual(viewModel.loginProperty.value, "a")
        XCTAssertEqual(viewModel.passwordProperty.value, "b")
    }

    func test_loginEmpty_passwordEmpty_shouldNotEnableButton() {

        loginObserver.send(value: "")
        passwordObserver.send(value: "")

        XCTAssertFalse(viewModel.isButtonEnabled.value)
    }

    func test_loginNotEmpty_passwordEmpty_shouldNotEnableButton() {

        loginObserver.send(value: "some")
        passwordObserver.send(value: "")

        XCTAssertFalse(viewModel.isButtonEnabled.value)
    }

    func test_loginEmpty_passwordNotEmpty_shouldNotEnableButton() {

        passwordObserver.send(value: "some")
        loginObserver.send(value: "")

        XCTAssertFalse(viewModel.isButtonEnabled.value)
    }

    func test_loginNotEmpty_passwordNotEmpty_shouldEnableButton() {

        passwordObserver.send(value: "some")
        loginObserver.send(value: "some")

        XCTAssertTrue(viewModel.isButtonEnabled.value)
    }

    func test_authTrigger_buttonDisabled_shouldNotTriggerRequest() {

        XCTAssertFalse(viewModel.isButtonEnabled.value)

        triggerObserver.send(value: ())

        XCTAssertFalse(viewModel.isLoading.value)
    }

    func test_authTrigger_buttonEnabled_shouldTriggerRequest() {

        passwordObserver.send(value: "some")
        loginObserver.send(value: "some")

        XCTAssertTrue(viewModel.isButtonEnabled.value)

        let exp = expectation(description: "Should trigger request")

        viewModel.authSignal.observeValues {
            exp.fulfill()
        }

        triggerObserver.send(value: ())

        XCTAssertFalse(viewModel.isButtonEnabled.value)
        XCTAssertTrue(viewModel.isLoading.value)

        wait(for: [exp], timeout: 0.1)

        XCTAssertFalse(viewModel.isLoading.value)
    }
}

private class MockLoginService: LoginServiceProtocol {

    func authenticate(login: String, password: String) -> SignalProducer<Void, Never> {

        return SignalProducer { observer, lifetime in
            DispatchQueue.main.async {
                observer.send(value: ())
                observer.sendCompleted()
            }
        }
    }
}
