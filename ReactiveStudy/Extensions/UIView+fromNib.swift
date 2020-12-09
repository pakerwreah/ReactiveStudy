import UIKit

extension UIView {
    static func fromNib() -> Self {
        guard let contentView = Bundle(for: Self.self)
            .loadNibNamed(String(describing: Self.self),
                          owner: self,
                          options: nil)?.first as? Self
            else { fatalError() }

        contentView.translatesAutoresizingMaskIntoConstraints = false

        return contentView
    }
}
