import UIKit

extension String {
    public func decodingHTMLEntities() -> String {
        guard let data = self.data(using: .utf8) else {
            return self
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        return self
    }
}

extension UIView {
    public func addInnerShadow() {
        let innerShadow = CALayer()
        innerShadow.name = "innerShadow"
        innerShadow.frame = bounds
        
        let radius = self.layer.cornerRadius
        let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: 0, dy: 1), cornerRadius: radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius: radius).reversing()
        
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        
        innerShadow.shadowColor = UIColor.white.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 2)
        innerShadow.shadowOpacity = 0.25
        innerShadow.shadowRadius = 2
        innerShadow.cornerRadius = self.layer.cornerRadius
        layer.addSublayer(innerShadow)
    }
    
    public func removeInnerShadow() {
        layer.sublayers?.forEach {
            if $0.name == "innerShadow" {
                $0.removeFromSuperlayer()
            }
        }
    }
}

extension Locale {
    public var isEnglish: Bool {
        return Locale.current.languageCode == "en"
    }
}

extension UIApplication {
    
    public class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}

extension UIViewController {
    
    public func pop() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    public func push(vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    public func present(vc: UIViewController, modalPresentationStyle: UIModalPresentationStyle? = .fullScreen, animated: Bool = true) {
        vc.modalPresentationStyle = modalPresentationStyle ?? .automatic
        DispatchQueue.main.async {
            self.present(vc, animated: animated)
        }
    }
    
    public func presentCrossDissolve(vc: UIViewController) {
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.view.backgroundColor = .clear
        vc.view.isOpaque = false
        DispatchQueue.main.async {
            self.present(vc, animated: true)
        }
    }
    
    public func dismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    public func popToRoot(animated: Bool = false) {
        self.navigationController?.popToRootViewController(animated: animated)
    }
    
    public func showAlert(title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(vc: alert)
    }
    
    public func replaceRootViewController(with viewController: UIViewController, animated: Bool = true) {
        guard let window = UIApplication.shared.windows.first else { return }
        
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        if animated {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    public func setupTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    public func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    public func applyGradientBorder(colors: [UIColor], lineWidth: CGFloat, cornerRadius: CGFloat) {
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradient.colors = colors.map { $0.cgColor }
        gradient.cornerRadius = cornerRadius
        
        let shape = CAShapeLayer()
        shape.lineWidth = lineWidth
        shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        
        gradient.mask = shape
        
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        
        self.layer.addSublayer(gradient)
    }
}

extension UIImage {
    public static func gradientImage(
        bounds: CGRect,
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5),
        endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5)
    ) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map(\.cgColor)
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        
        return renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
    }
}

extension Date {
    func formattedDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: self)
    }
}

extension UIDevice {
    var hasHomeButton: Bool {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return true }
        
        return window.safeAreaInsets.top <= 20
    }
    
    var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension UILabel {
    func highlightText(_ text: String, with color: UIColor) {
        guard let labelText = self.text else { return }
        
        let attributedString = NSMutableAttributedString(string: labelText)
        let range = (labelText as NSString).range(of: text)
        attributedString.addAttribute(.foregroundColor, value: color, range: range)
        
        self.attributedText = attributedString
    }
}

extension UIScreen {
    public static var isLittleDevice: Bool = UIScreen.main.bounds.height < 852.0
    public static var isBigDevice: Bool = UIScreen.main.bounds.height >= 874.0
}

extension UIView {
    
    public func add(target: Any?, action: Selector) {
        let recognizer = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(recognizer)
    }
}

extension UIColor {
    public convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension String {
    
    public var localized: String {
        return NSLocalizedString(self, comment: "\(self)_comment")
    }
}

public protocol Apply {}

public extension Apply where Self: AnyObject {
    @discardableResult
    public func apply(_ closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: Apply {}

extension String {

    public func attributedString(font: UIFont?, aligment: NSTextAlignment = .center, color: UIColor, lineSpacing: CGFloat = 0, maxHeight: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.maximumLineHeight = maxHeight
        paragraphStyle.alignment = aligment
        paragraphStyle.lineHeightMultiple = 1
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font!,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
        ]
        
        return NSAttributedString(string: self, attributes: attributes)
    }
}

extension Collection {
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

