import ReactiveSwift

extension Signal {
    func toVoid() -> Signal<Void, Error> {
        return map(value: ())
    }
}

extension Signal where Value == Bool {
    func filterIsTrue() -> Signal<Bool, Error> {
        return filter { $0 }
    }
}
