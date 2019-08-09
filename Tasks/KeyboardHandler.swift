//
//  KeyboardHandler.swift
//  Tasks
//

import UIKit

protocol KeyboardHandler: class {
    
    func keyboardWillShow(_ notification: Notification)
    func keyboardWillHide(_ notification: Notification)
    
    func startObservingKeyboardChanges()
    func stopObservingKeyboardChanges()
}

extension KeyboardHandler where Self: UIViewController {
    
    func startObservingKeyboardChanges() {
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardWillShow(notification)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardWillHide(notification)
        }
    }
    
    func stopObservingKeyboardChanges() {
        NotificationCenter.default.removeObserver(self)
    }
}
