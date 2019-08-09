//
//  PullIconView.swift
//  Tasks
//

import UIKit

class PullIconView: UIView {
    
    
    // MARK: Properties
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var plusView: UIImageView!
    @IBOutlet weak var arrowContainerView: UIView!
    @IBOutlet weak var arrowTopConstraint: NSLayoutConstraint!
    
    var circleView: UIView = UIView()
    var progressCircle: CAShapeLayer = CAShapeLayer()
    
    var animating: Bool = false
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    @discardableResult
    func fromNib<T : UIView>() -> T? {
        guard let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {
            // xib not loaded, or its top view is of the wrong type
            return nil
        }
        self.addSubview(view)
        return view
    }
    
    private func commonInit() {
        fromNib()
        
        plusView.isHidden = true
        
        /*
        arrowContainerView.layer.cornerRadius = arrowContainerView.bounds.size.width/2
        arrowContainerView.clipsToBounds = true
        */
        
        // Progress view
        let frame = CGRect.init(x: 6, y: 6, width: 32.0, height: 32.0)
        circleView.frame = frame
        contentView.addSubview(circleView)
        
        let lineWidth: CGFloat = 2.0
        let center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        
        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: (frame.size.width/2) - (lineWidth/2),
                                      startAngle: CGFloat(-0.5 * .pi),
                                      endAngle: CGFloat(1.5 * .pi),
                                      clockwise: true)
        
        progressCircle.path = circlePath.cgPath
        progressCircle.strokeColor = #colorLiteral(red: 0.2525674105, green: 0.2460785806, blue: 0.3024596572, alpha: 1)
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = lineWidth
        
        circleView.layer.addSublayer(progressCircle)
    }
    
    
    // MARK: Methods
    
    func toggleAnimation(animate: Bool) {
        
        let start: CGFloat = 14.0
        let end: CGFloat = 4.0
        
        if animate {
            if !animating {
                animating = true
                
                // Begin repeating animation
                UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [.repeat, .autoreverse, .curveEaseOut], animations: {
                    self.arrowTopConstraint.constant = end
                    self.layoutIfNeeded()
                }, completion: nil)
            }
        } else {
            if animating {
                animating = false
                
                // End animation and reset
                arrowContainerView.layer.removeAllAnimations()
                arrowTopConstraint.constant = start
                layoutIfNeeded()
            }
        }
    }
    
    func togglePlusIcon(visible: Bool) {
        plusView.isHidden = !visible
        arrowContainerView.isHidden = visible
        circleView.isHidden = visible
        //toggleAnimation(animate: !visible)
    }
    
    func setProgress(percent: CGFloat) {
        if !circleView.isHidden {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.0)
            progressCircle.strokeEnd = percent
            CATransaction.commit()
        }
    }

}
