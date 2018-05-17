//
//  PaycheckTableViewCell.swift
//  Budget
//
//  Created by Adam Moore on 5/17/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class PaycheckTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var paycheckCellView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
