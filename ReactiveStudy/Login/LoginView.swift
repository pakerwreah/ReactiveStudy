import UIKit
import ReactiveCocoa
import ReactiveSwift

class LoginView: UIView {
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    func setUp(with viewModel: LoginViewModel) {
        viewModel.setUp(loginSignal: loginTextField.reactive.continuousTextValues,
                        passwordSignal: passwordTextField.reactive.continuousTextValues,
                        buttonTapped: signInButton.reactive.controlEvents(.touchUpInside).map(value: ()))

        signInButton.reactive.isEnabled <~ viewModel.isButtonEnabled
        signInButton.reactive.alpha <~ viewModel.isButtonEnabled.map { $0 ? 1 : 0.3 }
    }
}
