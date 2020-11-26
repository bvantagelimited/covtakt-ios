//
//  IntroViewController.swift
//  OpenTrace

import UIKit
import FirebaseAuth
import Localize_Swift
class IntroViewController: UIViewController {
    @IBOutlet weak var govLogo: UIImageView!
    override func viewDidLoad() {
        Localize.setCurrentLanguage("en")
        
        super.viewDidLoad()
        
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
