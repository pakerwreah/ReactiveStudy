import ReactiveSwift

protocol LoginServiceProtocol {
    func authenticate(login: String, password: String) -> SignalProducer<Void, Never>
}

class LoginServiceProvider: LoginServiceProtocol {
    func authenticate(login: String, password: String) -> SignalProducer<Void, Never> {
        SignalProducer(value: ()).delay(2, on: QueueScheduler())
    }
}
