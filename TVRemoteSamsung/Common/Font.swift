import UIKit

struct Font {
    enum Weight: String {
        case regular = "Alexandria-Regular"
        case medium = "Alexandria-Medium"
        case semiBold = "Alexandria-SemiBold"
        case bold = "Alexandria-Bold"
        case extraBold = "Alexandria-ExtraBold"
        case black = "Alexandria-Black"
    }

    static func font(weight: Weight, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

extension UIFont {
    static func font(weight: Font.Weight, size: CGFloat) -> UIFont {
        return Font.font(weight: weight, size: size)
    }
}
