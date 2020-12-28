import ReactiveSwift

class LoginViewModel {
    private let loginProperty = MutableProperty<String>("")
    private let passwordProperty = MutableProperty<String>("")
    private let loadingProperty = MutableProperty<Bool>(false)
    private let buttonEnabledProperty = MutableProperty<Bool>(false)
    private let authObserver: Signal<Void, Never>.Observer

    let authSignal: Signal<Void, Never>
    let isButtonEnabled: Property<Bool>
    let isLoading: Property<Bool>
    let login: Property<String>
    let password: Property<String>

    private let loginService: LoginServiceProtocol

    init(loginService: LoginServiceProtocol) {

        self.loginService = loginService

        (authSignal, authObserver) = Signal.pipe()

        isLoading = Property(loadingProperty)
        isButtonEnabled = Property(buttonEnabledProperty)
        login = Property(loginProperty)
        password = Property(passwordProperty)

        buttonEnabledProperty <~ Property.combineLatest(
            login, password, isLoading
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

        let startRequest = authTrigger.withLatest(from: isButtonEnabled).filter(\.1).toVoid()

        loadingProperty <~ startRequest.map(value: true).merge(with: authSignal.map(value: false))

        authObserver <~ startRequest
            .withLatest(from: login.combineLatest(with: password))
            .map(\.1)
            .flatMap(.latest, loginService.authenticate)
    }

    private func normalized(_ value: String) -> String {
        value.replacingOccurrences(of: " ", with: "")
    }
}
