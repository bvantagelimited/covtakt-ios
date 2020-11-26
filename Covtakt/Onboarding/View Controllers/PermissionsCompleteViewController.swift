//
//  PermissionsCompleteViewController.swift
//  OpenTrace

import UIKit
import Localize_Swift
class PermissionsCompleteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Localize.setCurrentLanguage("en")
        BlueTraceLocalNotifications.shared.checkAuthorization { (granted) in
           
        }
    }
}
