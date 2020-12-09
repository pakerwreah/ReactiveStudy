import ReactiveSwift

class LoginViewModel {
    private let loginObserver: Signal<String, Never>.Observer
    private let passwordObserver: Signal<String, Never>.Observer
    private let authObserver: Signal<Void, Never>.Observer
    private let loadingProperty = MutableProperty<Bool>(false)
    private let buttonEnabledProperty = MutableProperty<Bool>(false)

    let loginSignal: Signal<String, Never>
    let passwordSignal: Signal<String, Never>
    let authSignal: Signal<Void, Never>
    var isButtonEnabled: Property<Bool>
    let isLoading: Property<Bool>

    init() {
        (loginSignal, loginObserver) = Signal.pipe()
        (passwordSignal, passwordObserver) = Signal.pipe()
        (authSignal, authObserver) = Signal.pipe()

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

        loginObserver <~ loginSignal.map {
            $0.trimmingCharacters(in: .whitespaces)
        }

        passwordObserver <~ passwordSignal.map {
            $0.trimmingCharacters(in: .whitespaces)
        }

        let buttonEnabledTapped = buttonTapped.withLatest(from: isButtonEnabled).filter { $1 }.toVoid()

        loadingProperty <~ buttonEnabledTapped.map(value: true).merge(with: authSignal.map(value: false))

        authObserver <~ buttonEnabledTapped.flatMap(.latest) {
            // network request
            SignalProducer(value: ()).delay(2, on: QueueScheduler())
        }
    }
}
