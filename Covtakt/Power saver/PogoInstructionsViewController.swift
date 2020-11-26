//
//  PogoInstructionsViewController.swift
//  OpenTrace

import UIKit

class PogoInstructionsViewController: UIViewController {

    @IBOutlet weak var keptOpenLabel: UILabel!
    @IBOutlet weak var faceDownLabel: UILabel!
    @IBOutlet weak var upsideDownLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let string1 = NSLocalizedString("On iPhone, the app needs to be kept open to work.", comment: "On iPhone, the app needs to be kept open to work.")
        let boldRange1 = NSRange(location: 0, length: 0)
        let attributedString1 = NSMutableAttributedString(string: string1)
        attributedString1.addAttribute(.font, value: UIFont(name: "Muli-Bold", size: 16)!, range: boldRange1)
        keptOpenLabel.attributedText = attributedString1

        let string2 = NSLocalizedString("1. Turn your phone face down, or", comment: "1. Turn your phone face down, or")
        let boldRange2 = NSRange(location: 20, length: 6)
        let attributedString2 = NSMutableAttributedString(string: string2)
        attributedString2.addAttribute(.font, value: UIFont(name: "Muli-Bold", size: 16)!, range: boldRange2)
        faceDownLabel.attributedText = attributedString2

        let string3 = NSLocalizedString("2. Keep it upside down in your pocket", comment: "2. Keep it upside down in your pocket")
        let boldRange3 = NSRange(location: string3.count - 8, length: 7)
        let attributedString3 = NSMutableAttributedString(string: string3)
        attributedString3.addAttribute(.font, value: UIFont(name: "Muli-Bold", size: 16)!, range: boldRange3)
        upsideDownLabel.attributedText = attributedString3
    }
}
