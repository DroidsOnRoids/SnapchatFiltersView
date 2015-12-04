//
//  FiltersImageView.swift
//

import Foundation
import UIKit

// hack, because of a current bug in Xcode
typealias CoreImageImage = CIImage

class FiltersImageView: UIView {
    
    // MARK: - private variables

    private var didSetupConstraints = false
    private var didLayout = false
    private let bottomImageView = UIImageView()
    private let topImageView = UIImageView()
    private var filters = CircularArray<CIFilter?>(array:
        [nil,
        CIFilter(name: "CIPhotoEffectChrome"),
        CIFilter(name: "CIPhotoEffectFade"),
        CIFilter(name: "CIPhotoEffectInstant"),
        CIFilter(name: "CIPhotoEffectMono"),
        CIFilter(name: "CIPhotoEffectTransfer"),
        CIFilter(name: "CIPhotoEffectProcess"),
        CIFilter(name: "CIPhotoEffectTonal"),
        CIFilter(name: "CIPhotoEffectNoir")])
    private var nextOrPrevious = false
    private var lastTranslation: CGFloat = 0
    private var lastAbsoluteTranslation: CGFloat = 0
    private var lastDirectionWasRight: Bool?
    private var topMaskLayer = CAShapeLayer()
    
    // MARK: - public  variables

    var image: UIImage? {
        didSet {
            bottomImageView.image = image
            topImageView.image = image
        }
    }

    // MARK: - init and setup
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    convenience init(image: UIImage) {
        self.init()
        self.image = image
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didPan:")
        addGestureRecognizer(panGestureRecognizer)
        
        addSubview(bottomImageView)
        addSubview(topImageView)
        setNeedsLayout()
        setNeedsUpdateConstraints()
    }
    
    override func layoutSubviews() {
        if !didLayout {
            didLayout = true
            
            clipsToBounds = true
            bottomImageView.frame = bounds
            bottomImageView.image = image
            bottomImageView.contentMode = .ScaleAspectFill
            topImageView.frame = bounds
            topImageView.image = image
            topImageView.contentMode = .ScaleAspectFill
            
            let topMaskPath = UIBezierPath(rect: CGRect(x: frame.width, y: 0, width: 0, height: frame.height))
            topMaskPath.closePath()
            topMaskLayer.path = topMaskPath.CGPath
            topMaskLayer.backgroundColor = UIColor.blackColor().CGColor

            topImageView.layer.mask = topMaskLayer
        }
        super.layoutSubviews()
    }
    
    private func setupConstraints() {
        didSetupConstraints = true
    }
    
    // MARK: - private functions
    
    // MARK: - public functions
    
    func didPan(recognizer: UIPanGestureRecognizer) {
        let vanillaTranslation = recognizer.translationInView(self).x
        let translation = vanillaTranslation >= 0 ? vanillaTranslation % frame.width : frame.width - (fabs(vanillaTranslation) % frame.width)
        
        switch recognizer.state {
        case .Began:
            nextOrPrevious = true
            lastTranslation = vanillaTranslation > 0 ? frame.width : 0
            lastAbsoluteTranslation = vanillaTranslation
            lastDirectionWasRight = nil
        case .Changed:
            let change = lastTranslation - (vanillaTranslation % frame.width)
            if fabs(change) > frame.width / 2 {
                nextOrPrevious = true
            }
            if (vanillaTranslation >= 0 && lastTranslation <= 0) {
                nextOrPrevious = true
            }
            if (vanillaTranslation <= 0 && lastTranslation >= 0) {
                nextOrPrevious = true
            }

            if nextOrPrevious {
                nextOrPrevious = false
                if lastAbsoluteTranslation - vanillaTranslation < 0 {
                    if let lastDirectionWasRight = lastDirectionWasRight where !lastDirectionWasRight {
                        filters.previous()
                    }
                    
                    bottomImageView.image = image?.filteredImage(filters.current())
                    topImageView.image = image?.filteredImage(filters.previous())
                    
                    lastDirectionWasRight = true
                }
                if lastAbsoluteTranslation - vanillaTranslation > 0 {
                    if let lastDirectionWasRight = lastDirectionWasRight where lastDirectionWasRight {
                        filters.next()
                    }

                    topImageView.image = image?.filteredImage(filters.current())
                    bottomImageView.image = image?.filteredImage(filters.next())
                    
                    lastDirectionWasRight = false
                }
            }
            lastTranslation = vanillaTranslation % frame.width
            lastAbsoluteTranslation = vanillaTranslation

            let topMaskPath = UIBezierPath(rect: CGRect(
                x: 0,
                y: 0,
                width: translation,
                height: frame.height))
            topMaskPath.closePath()
            topMaskLayer.path = topMaskPath.CGPath
        case .Ended, .Cancelled:
            let visibleMaskPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            visibleMaskPath.closePath()
            
            let hiddenMaskPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 0, height: frame.height))
            hiddenMaskPath.closePath()
            
            if translation <= frame.width / 2 {
                if let lastDirectionWasRight = lastDirectionWasRight where lastDirectionWasRight {
                    filters.next()
                }
                topMaskLayer.animatePath(hiddenMaskPath.CGPath)
            } else {
                if let lastDirectionWasRight = lastDirectionWasRight where !lastDirectionWasRight {
                    filters.previous()
                }
                topMaskLayer.animatePath(visibleMaskPath.CGPath)
            }
        default:
            ()
        }
    }
    
    // MARK: - class functions
    
}

extension UIImage {
    func filteredImage(filter: CIFilter?) -> UIImage {
        guard let filter = filter else { return self }
        let context = CIContext(options: nil)
        let image = CoreImageImage(image: self)
        
        filter.setValue(image, forKey: kCIInputImageKey)
        guard let result = filter.valueForKey(kCIOutputImageKey) as? CoreImageImage else { return self }
        
        let extent = result.extent
        let cgImage = context.createCGImage(result, fromRect: extent)
        
        return UIImage(CGImage: cgImage, scale: scale, orientation: imageOrientation) ?? self
    }
}

extension CAShapeLayer {
    func animatePath(newPath: CGPathRef) {
        let fromValue = path
        
        path = newPath
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.duration = 0.3
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pathAnimation.fromValue = fromValue
        
        addAnimation(pathAnimation, forKey: "path")
    }
}
