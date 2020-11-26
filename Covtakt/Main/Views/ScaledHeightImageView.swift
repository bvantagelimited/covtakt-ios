//
//  ScaledHeightImageView.swift
//  Covtakt
//
//  Created by IPification on 15/5/2020.
//  Copyright © 2020 OpenTrace. All rights reserved.
//

import Foundation
import UIKit
class ScaledHeightImageView: UIImageView {

    override var intrinsicContentSize: CGSize {

        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width

            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio

            return CGSize(width: myViewWidth, height: scaledHeight)
        }

        return CGSize(width: -1.0, height: -1.0)
    }

}
