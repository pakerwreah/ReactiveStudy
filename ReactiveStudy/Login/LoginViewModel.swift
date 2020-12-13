import ReactiveSwift

class LoginViewModel {
    private let loadingProperty = MutableProperty<Bool>(false)
    private let buttonEnabledProperty = MutableProperty<Bool>(false)
    private let authObserver: Signal<Void, Never>.Observer
    private let loginService: LoginServiceProtocol

    let loginProperty = MutableProperty<String>("")
    let passwordProperty = MutableProperty<String>("")

    let authSignal: Signal<Void, Never>
    var isButtonEnabled: Property<Bool>
    let isLoading: Property<Bool>

    init(loginService: LoginServiceProtocol) {

        self.loginService = loginService

        (authSignal, authObserver) = Signal.pipe()
        
        isLoading = Property(loadingProperty)
        isButtonEnabled = Property(buttonEnabledProperty)

        buttonEnabledProperty <~ Property.combineLatest(
            loginProperty, passwordProperty, isLoading
        )
        .map { login, password, isLoading in
            !login.isEmpty && !password.isEmpty && !isLoading
        }
    }

    func setUp(loginChanged: Signal<String, Never>,
               passwordChanged: Signal<String, Never>,
               authTrigger: Signal<Void, Never>) {

        loginProperty <~ loginChanged.map(normalized)
        passwordProperty <~ passwordChanged.map(normalized)

        let startRequest = authTrigger.withLatest(from: isButtonEnabled).filter { $1 }.toVoid()

        loadingProperty <~ startRequest.map(value: true).merge(with: authSignal.map(value: false))

        authObserver <~ startRequest
            .withLatest(from: loginProperty.combineLatest(with: passwordProperty))
            .map { $1 }
            .flatMap(.latest, loginService.authenticate)
    }

    private func normalized(_ value: String) -> String {
        value.replacingOccurrences(of: " ", with: "")
    }
}
