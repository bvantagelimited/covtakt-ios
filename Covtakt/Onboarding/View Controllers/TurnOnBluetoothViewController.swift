//
//  TurnOnBluetoothViewController.swift
//  OpenTrace

import UIKit
import Localize_Swift
class TurnOnBluetoothViewController: UIViewController {

    @IBAction func enabledBluetoothBtn(_ sender: UIButton) {

        OnboardingManager.shared.completedBluetoothOnboarding = true

        self.performSegue(withIdentifier: "showFullySetUpFromTurnOnBtSegue", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Localize.setCurrentLanguage("en")
    }

}
