import ReactiveSwift

extension Signal {
    func toVoid() -> Signal<Void, Error> {
        return map(value: ())
    }
}
