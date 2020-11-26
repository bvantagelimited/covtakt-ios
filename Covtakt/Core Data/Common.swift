//
//  Common.swift
//  Covtakt
//
//  Created by IPification on 25/4/2020.
//  Copyright © 2020 OpenTrace. All rights reserved.
//

import Foundation
import UIKit
extension UIView {

    enum Visibility: String {
        case visible = "visible"
        case invisible = "invisible"
        case gone = "gone"
    }

    var visibility: Visibility {
        get {
            let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
            if let constraint = constraint, constraint.isActive {
                return .gone
            } else {
                return self.isHidden ? .invisible : .visible
            }
        }
        set {
            if self.visibility != newValue {
                self.setVisibility(newValue)
            }
        }
    }

    @IBInspectable
    var visibilityState: String {
        get {
            return self.visibility.rawValue
        }
        set {
            let _visibility = Visibility(rawValue: newValue)!
            self.visibility = _visibility
        }
    }

    private func setVisibility(_ visibility: Visibility) {
        let constraints = self.constraints.filter({$0.firstAttribute == .height && $0.constant == 0 && $0.secondItem == nil && ($0.firstItem as? UIView) == self})
        let constraint = (constraints.first)

        switch visibility {
        case .visible:
            constraint?.isActive = false
            UIView.self.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
//                self.alpha = 1
                self.isHidden = false
            })
            break
        case .invisible:
            constraint?.isActive = false
            UIView.self.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.isHidden = true
            })
            
            break
        case .gone:
            UIView.self.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
//                self.alpha = 0
                self.isHidden = true
            })
            if let constraint = constraint {
                constraint.isActive = true
            } else {
                let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
                // constraint.priority = UILayoutPriority(rawValue: 999)
                self.addConstraint(constraint)
                constraint.isActive = true
            }
            self.setNeedsLayout()
            self.setNeedsUpdateConstraints()
        }
    }
}


extension UIColor {
    convenience init(hexString:String) {
        let hexString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner            = Scanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0

        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
}


struct Notif {
    var date: Date
    var message: String
    init(date: Date, message: String) {
        self.date = date
        self.message = message
    }
}
extension Date {

    var timeAgoSinceNow: String {
        return getTimeAgoSinceNow()
    }

    private func getTimeAgoSinceNow() -> String {

        var interval = Calendar.current.dateComponents([.year], from: self, to: Date()).year!
        if interval > 0 {
            return interval == 1 ? "pre godinu" : "pre " + "\(interval)" + " godine"
        }

        interval = Calendar.current.dateComponents([.month], from: self, to: Date()).month!
        if interval > 0 {
            return interval == 1 ? "pre mesec" :  "pre " + "\(interval)" + " meseca"
        }

        interval = Calendar.current.dateComponents([.day], from: self, to: Date()).day!
        if interval > 0 {
            return interval == 1 ? "juče" : "pre " + "\(interval)" + " dana"
        }

        interval = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour!
        if interval > 0 {
            return interval == 1 ? "pre sat" : "pre " +  "\(interval)" + " sata"
        }

        interval = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute!
        if interval > 0 {
            return interval == 1 ? "pre minut" : "pre " +  "\(interval)" + " minuta"
        }

        return "malopre"
    }
}
