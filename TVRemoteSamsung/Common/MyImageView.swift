import UIKit

@IBDesignable
class MyImageView: UIView {
    
    enum HorizontalAlignment: String {
        case left, center, right
    }
    
    enum VerticalAlignment: String {
        case top, center, bottom
    }
    
    private var theImageView: UIImageView = {
        let v = UIImageView()
        return v
    }()
    
    @IBInspectable var image: UIImage? {
        get { return theImageView.image }
        set {
            theImageView.image = newValue
            setNeedsLayout()
        }
    }
    
    @IBInspectable var hAlign: String = "center" {
        willSet {
            if let newAlign = HorizontalAlignment(rawValue: newValue.lowercased()) {
                horizontalAlignment = newAlign
            }
        }
    }
    
    @IBInspectable var vAlign: String = "center" {
        willSet {
            if let newAlign = VerticalAlignment(rawValue: newValue.lowercased()) {
                verticalAlignment = newAlign
            }
        }
    }
    
    @IBInspectable var aspectFill: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    var horizontalAlignment: HorizontalAlignment = .center
    var verticalAlignment: VerticalAlignment = .center
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    func commonInit() -> Void {
        clipsToBounds = true
        addSubview(theImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let img = theImageView.image else {
            return
        }
        
        var newRect = bounds
        
        let viewRatio = bounds.size.width / bounds.size.height
        let imgRatio = img.size.width / img.size.height
        
        if viewRatio == imgRatio {
            theImageView.frame = newRect
            return
        }
        

        var calcMode: Int = 1
        if aspectFill {
            calcMode = imgRatio > 1.0 ? 1 : 2
        } else {
            calcMode = imgRatio < 1.0 ? 1 : 2
        }

        if calcMode == 1 {
            let heightFactor = bounds.size.height / img.size.height
            let w = img.size.width * heightFactor
            newRect.size.width = w
            switch horizontalAlignment {
            case .center:
                newRect.origin.x = (bounds.size.width - w) * 0.5
            case .right:
                newRect.origin.x = bounds.size.width - w
            default: break
            }
        } else {
            let widthFactor = bounds.size.width / img.size.width
            let h = img.size.height * widthFactor
            newRect.size.height = h
            switch verticalAlignment {
            case .center:
                newRect.origin.y = (bounds.size.height - h) * 0.5
            case .bottom:
                newRect.origin.y = bounds.size.height - h
            default: break
            }
        }

        theImageView.frame = newRect
    }
}

