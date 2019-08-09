//
//  WelcomeViewController.swift
//  Tasks
//

import UIKit
import UserNotifications

class WelcomeViewController: UIViewController {


    // MARK: Properties
    
    @IBOutlet weak var notificationsButton: UIButton!
    

    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationsButton.layer.cornerRadius = 20
    }
    

    // MARK: Actions

    @IBAction func notificationsButtonPressed(_ sender: UIButton) {
        
        // Prompt for notifications permission
        UNUserNotificationCenter.current().requestAuthorization(options: .badge) { (granted, error) in
            if (error != nil) {
                // success...
            }
            
            // Dismiss view controller
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }
        return instantiateFromNib()
    }
}
