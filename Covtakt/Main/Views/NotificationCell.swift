//
//  CategoryCell.swift
//  ezyHelpers
//
//  Created by Do Tri on 4/17/16.
//  Copyright © 2016 Do Tri. All rights reserved.
//

import UIKit


class NotificationCell: UITableViewCell {
    
    

    @IBOutlet weak var shortLabel: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
