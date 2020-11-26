//
//  HowItWorksViewController.swift
//  OpenTrace

import UIKit
import FirebaseAuth
import Localize_Swift
class HowItWorksViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBAction func greatBtnOnClick(_ sender: UIButton) {
        
        OnboardingManager.shared.completedIWantToHelp = true
        if Auth.auth().currentUser == nil {
           doAnynomousAuth(true)
        } else {
           result()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doAnynomousAuth()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    @IBAction func showPrivacy(_ sender: Any) {
        self.performSegue(withIdentifier: "showWebView", sender: nil)
    }
    func doAnynomousAuth(_ isForce: Bool = false) {
        indicator.startAnimating()
        button.isEnabled = false // disables
        button.setTitle("...", for: .normal) // sets text

        Auth.auth().signInAnonymously() {(authResult, error) in
            if let error = error as NSError? {
                print(error.code, error.localizedDescription)
                self.indicator.stopAnimating()
                self.button.isEnabled = true // disables
                self.button.setTitle(NSLocalizedString("Great!!!", comment: "Great!!!"), for: .normal) // sets text
                return
            }
            print(authResult?.user.uid)
            UserDefaults.standard.set(authResult?.user.uid, forKey: OTPViewController.userDefaultsPinKey)
            if(isForce) {
                  self.result()
            }
            self.indicator.stopAnimating()
            self.button.isEnabled = true // disables
            self.button.setTitle(NSLocalizedString("Great!!!" , comment: "Great!!!"), for: .normal) // sets text
        }
    }
    func result () {
        EncounterMessageManager.shared.setup()
        BlueTraceLocalNotifications.shared.initialConfiguration()
        self.performSegue(withIdentifier: "iWantToHelpToConsentSegue", sender: self)
    }
}
