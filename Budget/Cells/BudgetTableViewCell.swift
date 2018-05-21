//
//  BudgetTableViewCell.swift
//  Budget
//
//  Created by Adam Moore on 5/10/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class BudgetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeFrameLabel: UILabel!

    @IBOutlet weak var budgetedTimeFrameView: UIView!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
