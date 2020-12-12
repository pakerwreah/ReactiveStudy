import UIKit
import ReactiveSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var loginViewContainer: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    private let viewModel = LoginViewModel(loginService: LoginServiceProvider())
    private let loginView = LoginView.fromNib()

    override func viewDidLoad() {
        super.viewDidLoad()

        loginView.bind(to: viewModel)

        loginViewContainer.addSubview(loginView)
        loginView.edges(to: loginViewContainer)

        loadingIndicator.reactive.isAnimating <~ viewModel.isLoading.signal
        view.reactive.endEditing <~ viewModel.isLoading.signal.toVoid()

        viewModel.authSignal.observe(on: UIScheduler()).observeValues { [weak self] in
            let alert = UIAlertController(title: "Success", message: "You are logged in!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

}
