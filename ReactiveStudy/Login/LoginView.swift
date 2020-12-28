import UIKit
import ReactiveCocoa
import ReactiveSwift

class LoginView: UIView {
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        passwordTextField.reactive.becomeFirstResponder <~ loginTextField.reactive.next
    }

    func bind(to viewModel: LoginViewModel) {
        viewModel.setUp(
            loginChanged: loginTextField.reactive.continuousTextValues,
            passwordChanged: passwordTextField.reactive.continuousTextValues,
            authTrigger: passwordTextField.reactive.next.merge(with: signInButton.reactive.tapped)
        )

        loginTextField.reactive.text <~ viewModel.login
        passwordTextField.reactive.text <~ viewModel.password

        signInButton.reactive.isEnabled <~ viewModel.isButtonEnabled
        signInButton.reactive.alpha <~ viewModel.isButtonEnabled.map { $0 ? 1 : 0.3 }
    }
}
