//
//  BudgetItemTableViewCell.swift
//  Budget
//
//  Created by Adam Moore on 5/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class BudgetItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var fromCategoryLabel: UILabel!
    
    @IBOutlet weak var amountAvailableLabel: UILabel!
    
    @IBOutlet weak var amountBudgetedLabel: UILabel!
    
    @IBOutlet weak var dueDayLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
