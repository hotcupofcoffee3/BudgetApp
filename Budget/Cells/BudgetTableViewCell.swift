//
//  BudgetTableViewCell.swift
//  Budget
//
//  Created by Adam Moore on 5/10/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class BudgetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var budgetedTimeFrameLabel: UILabel!

    @IBOutlet weak var budgetedTimeFrameView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
