import ReactiveSwift

class LoginViewModel {
    private let loginPipe = Signal<String, Never>.pipe()
    private let passwordPipe = Signal<String, Never>.pipe()
    private let authPipe = Signal<Void, Never>.pipe()
    private let loadingProperty = MutableProperty<Bool>(false)
    private let buttonEnabledProperty = MutableProperty<Bool>(false)

    let loginSignal: Signal<String, Never>
    let passwordSignal: Signal<String, Never>
    let authSignal: Signal<Void, Never>
    var isButtonEnabled: Property<Bool>
    let isLoading: Property<Bool>

    init() {
        loginSignal = loginPipe.output
        passwordSignal = passwordPipe.output
        authSignal = authPipe.output
        isLoading = Property(loadingProperty)
        isButtonEnabled = Property(buttonEnabledProperty)

        buttonEnabledProperty <~ SignalProducer.combineLatest(
            loginSignal.producer, passwordSignal.producer, isLoading.producer
        ).map { login, password, isLoading in
            !login.isEmpty && !password.isEmpty && !isLoading
        }
    }

    func setUp(loginSignal: Signal<String, Never>,
               passwordSignal: Signal<String, Never>,
               buttonTapped: Signal<Void, Never>) {

        loginPipe.input <~ loginSignal.map {
            $0.trimmingCharacters(in: .whitespaces)
        }

        passwordPipe.input <~ passwordSignal.map {
            $0.trimmingCharacters(in: .whitespaces)
        }

        loadingProperty <~ buttonTapped.map(value: true).merge(with: authSignal.map(value: false))

        authPipe.input <~ buttonTapped.flatMap(.latest) {
            // network request
            SignalProducer(value: true).delay(2, on: QueueScheduler())
        }
        .filter { $0 }
        .map(value: ())
    }
}
