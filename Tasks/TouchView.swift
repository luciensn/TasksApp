//
//  TouchView.swift
//  Tasks
//

import UIKit

class TouchView: UIView, UIGestureRecognizerDelegate {
    
    /*
     *
     * Make your view controller's view a TouchView to simulate
     * showing touch events when recording screencast videos using
     * the Xcode simulator.
     *
     * Terminal command to record videos with the simulator:
     * xcrun simctl io booted recordVideo <filename>.mov
     *
     */
    
    
    // MARK: Properties
    
    let touchIndicator = UIView()
    
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        touchIndicator.isHidden = false
        touchIndicator.isUserInteractionEnabled = false
        touchIndicator.frame = CGRect.init(x: 44, y: 44, width: 44, height: 44)
        touchIndicator.layer.cornerRadius = touchIndicator.frame.size.width/2
        touchIndicator.backgroundColor = UIColor.white
        touchIndicator.layer.borderWidth = 2.0
        touchIndicator.layer.borderColor = UIColor.lightGray.cgColor
        touchIndicator.alpha = 0.8
        self.addSubview(touchIndicator)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(gesture:)))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(gesture:)))
        pan.delegate = self
        pan.cancelsTouchesInView = false
        self.addGestureRecognizer(pan)
    }
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        bringSubviewToFront(touchIndicator)
    }
    
    
    // MARK: Gesture Recognizer
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handleTap(gesture: UIGestureRecognizer) {

        let point = gesture.location(in: self)
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
            self.touchIndicator.center = point
        }, completion: nil)
        
    }
    
    @objc func handlePan(gesture: UIGestureRecognizer) {

        let point = gesture.location(in: self)
        touchIndicator.center = point
        
    }

}
