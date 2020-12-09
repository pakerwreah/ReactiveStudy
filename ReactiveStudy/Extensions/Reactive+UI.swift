import ReactiveSwift

extension Reactive where Base: UIView {
    var endEditing: BindingTarget<Void> {
        return makeBindingTarget { view, _ in view.endEditing(true) }
    }
}

extension Reactive where Base: UITextField {
    var next: Signal<Void, Never> {
        controlEvents(.primaryActionTriggered).toVoid()
    }
}

extension Reactive where Base: UIButton {
    var tapped: Signal<Void, Never> {
        controlEvents(.touchUpInside).toVoid()
    }
}
